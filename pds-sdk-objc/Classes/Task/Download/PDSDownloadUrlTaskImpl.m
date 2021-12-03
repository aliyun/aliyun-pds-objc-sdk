// /*
// * Copyright 2009-2021 Alibaba Cloud All rights reserved.
// *
// * Licensed under the Apache License, Version 2.0 (the "License");
// * you may not use this file except in compliance with the License.
// * You may obtain a copy of the License at
// *
// *      http://www.apache.org/licenses/LICENSE-2.0
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// *

#import "PDSDownloadUrlTaskImpl.h"
#import "PDSTaskValidator.h"
#import "PDSTaskFolderExistValidator.h"
#import "PDSTaskDiskCapacityValidator.h"
#import "PDSTaskValidatorChecker.h"
#import "PDSInternalParallelDownloadTask.h"
#import "PDSDownloadUrlRequest.h"
#import "PDSSessionDelegate.h"
#import "PDSInternalHashTask.h"
#import "PDSRequestError.h"
#import "NSFileManager+PDS.h"
#import "PDSError.h"
#import "NSError+PDS.h"
#import "PDSTransportClient.h"
#import "PDSAPIGetDownloadUrlRequest.h"
#import "PDSAPIGetDownloadUrlResponse.h"
#import "PDSAPIRequestTask.h"
#import "PDSMacro.h"
#import <extobjc/EXTScope.h>

typedef NS_ENUM(NSUInteger, PDSDownloadUrlTaskStatus) {
    PDSDownloadUrlTaskStatusInit = 0,
    PDSDownloadUrlTaskStatusRefreshUrl = 2,
    PDSDownloadUrlTaskStatusDownloading = 10,
    PDSDownloadUrlTaskStatusDownloaded = 11,
    PDSDownloadUrlTaskStatusHashing = 100,
    PDSDownloadUrlTaskStatusFinished = 1000
};

static const int kPDSDownloadTaskMaxFailRetryCount = 3;

static const int kMaxRenameCount = 10;

@interface PDSDownloadUrlTaskImpl ()
@property(nonatomic, assign) PDSDownloadUrlTaskStatus status;
@property(nonatomic, strong) PDSInternalParallelDownloadTask *downloadTask;
@property(nonatomic, strong) PDSAPIRequestTask *getDownloadUrlTask;
@property(nonatomic, strong) PDSInternalHashTask *hashTask;
@property(nonatomic, weak) PDSSessionDelegate *sessionDelegate;
@property(nonatomic, weak) NSURLSession *session;
@property(nonatomic, weak) PDSTransportClient *transportClient;
@property(nonatomic, strong) PDSDownloadUrlRequest *request;
@property(nonatomic, strong) PDSRequestError *requestError;
@property(nonatomic, strong) PDSFileMetadata *resultData;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, assign) BOOL cancelled;
@property(nonatomic, assign) BOOL suspended;
@property(nonatomic, assign) BOOL started;
@end

@implementation PDSDownloadUrlTaskImpl {
    PDSDownloadUrlResponseBlock _responseBlock;
    NSOperationQueue *_responseQueue;
    PDSProgressBlock _progressBlock;
    NSOperationQueue *_progressQueue;
}

- (id)initWithRequest:(PDSDownloadUrlRequest *)request identifier:(NSString *)identifier session:(NSURLSession *)session sessionDelegate:(PDSSessionDelegate *)sessionDelegate transportClient:(PDSTransportClient *)transportClient {
    self = [self initWithIdentifier:identifier];
    self.request = request;
    self.session = session;
    self.sessionDelegate = sessionDelegate;
    self.transportClient = transportClient;
    [self setup];
    return self;
}


- (void)setup {
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.status = PDSDownloadUrlTaskStatusInit;
}

#pragma mark Task Actions

- (void)cancel {
    @synchronized (self) {
        self.cancelled = YES;
        [self.downloadTask cancel];
        [self.hashTask cancel];
    }
}

- (void)suspend {
    @synchronized (self) {
        self.suspended = YES;
        if (self.status == PDSDownloadUrlTaskStatusHashing) {
            [self.hashTask cancel];
        } else if (self.status == PDSDownloadUrlTaskStatusDownloading) {
            [self.downloadTask suspend];
        }
    }
}

- (void)resume {
    @weakify(self);
    @synchronized (self) {
        if (self.cancelled || self.isFinished) {
            return;
        }
        self.suspended = NO;
        if (!self.started) {//全新的任务
            self.started = YES;
            [self _restoreWithCompletion:^{
                @strongify(self);
                [self _start];
            }];
        } else {
            [self _start];
        }
    }
}

- (void)start {
    [self resume];
}

- (PDSTask *)restart {
    PDSDownloadUrlTask *task = [[PDSDownloadUrlTaskImpl alloc] initWithRequest:self.request
                                                                    identifier:self.taskIdentifier
                                                                       session:self.session
                                                               sessionDelegate:self.sessionDelegate
                                                               transportClient:self.transportClient];
    [task setResponseBlock:_responseBlock queue:_responseQueue];
    [task setProgressBlock:_progressBlock queue:_progressQueue];
    task.retryCount = self.retryCount + 1;
    [task resume];
    return task;
}

#pragma mark Private Method

- (void)_restoreWithCompletion:(void (^)())completion {
    if (completion) {
        completion();
    }
}


- (void)_start {
    [self processStatus];
}

- (void)processStatus {
    PDSDownloadUrlTaskStatus status = PDSDownloadUrlTaskStatusInit;
    @synchronized (self) {
        status = self.status;
    }
    switch (status) {
        case PDSDownloadUrlTaskStatusInit:
            [self prepareEnv];
            break;
        case PDSDownloadUrlTaskStatusRefreshUrl:
            [self refreshUrl];
            break;
        case PDSDownloadUrlTaskStatusDownloading:
            [self startDownload];
            break;
        case PDSDownloadUrlTaskStatusDownloaded:
            [self validate];
            break;
        case PDSDownloadUrlTaskStatusFinished:
            [self callResponseBlockIfNeeded];
            break;
        default:
            break;
    }
}

- (void)prepareEnv {
    NSError *error = nil;
    BOOL validated = [self check:&error];
    if (!validated) {//校验失败，磁盘空间不够、文件名过长等等
        @synchronized (self) {
            self.status = PDSDownloadUrlTaskStatusFinished;
        }
        [self processStatus];
        return;
    }
    [self prepareFile];
    @synchronized (self) {
        self.status = PDSDownloadUrlTaskStatusDownloading;
    }
    [self processStatus];
}

- (void)startDownload {
    //初始化下载任务
    self.downloadTask = [[PDSInternalParallelDownloadTask alloc] initWithRequest:self.request identifier:self.taskIdentifier session:self.session sessionDelegate:self.sessionDelegate];
    @weakify(self);
    [self.downloadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        @strongify(self);
        if (self == nil) {
            return;
        }
        PDSProgressBlock progressBlock = nil;
        NSOperationQueue *toUseQueue = nil;
        @synchronized (self) {
            progressBlock = self->_progressBlock;
            toUseQueue = self->_progressQueue;
        }
        if (progressBlock) {
            toUseQueue = toUseQueue ?: [NSOperationQueue mainQueue];
            [toUseQueue addOperationWithBlock:^{
                progressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            }];
        }
    }];

    [self.downloadTask setResponseBlock:^(BOOL finished, PDSRequestError *networkError) {
        @strongify(self);
        if (self == nil) {
            return;
        }
        if (!networkError) {//下载完成
            @synchronized (self) {
                self.status = PDSDownloadUrlTaskStatusDownloaded;
                [self processStatus];
            }
        } else {//失败了
            if(networkError.statusCode == 403) {// 下载链接过期，需要重新刷新
                @synchronized (self) {
                    self.status = PDSDownloadUrlTaskStatusRefreshUrl;
                    [self processStatus];
                }
                return;
            }
            @synchronized (self) {
                //返回失败原因
                self.requestError = networkError;
                self.status = PDSDownloadUrlTaskStatusFinished;
                [self processStatus];
            }
        }
    } queue:self.operationQueue];
    [self.downloadTask resume];
}

- (BOOL)check:(NSError **)error {
    PDSTaskFolderExistValidator *folderExistValidator = [PDSTaskFolderExistValidator validatorWithFolderPath:
                                                                                             [self.request.destination stringByDeletingLastPathComponent]];
    PDSTaskDiskCapacityValidator *diskCapacityValidator = [PDSTaskDiskCapacityValidator validatorWithSize:self.request.fileSize];
    NSArray *validators = @[
            folderExistValidator,
            diskCapacityValidator];
    BOOL validated = [PDSTaskValidatorChecker passValidators:validators error:error];
    return validated;
}

- (void)prepareFile {
    //处理文件名
    BOOL isDirectory = NO;
    NSString *destination = self.request.destination;
    BOOL isNameOK = [[NSFileManager defaultManager] pds_autoRenameFile:&destination];
    if(!isNameOK) {
        // 重命名失败
        NSError *error = [NSError pds_errorWithCode:PDSErrorFileNameConflict];
        @synchronized (self) {
            self.requestError = [[PDSRequestError alloc] initAsClientError:error];
            self.status = PDSDownloadUrlTaskStatusFinished;
            [self callResponseBlockIfNeeded];
            return;
        }
    }
    else {
        //创建空文件
        [[NSFileManager defaultManager] createFileAtPath:destination contents:nil attributes:nil];
        if (![destination isEqualToString:self.request.destination]) {
            self.request = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:self.request.downloadUrl destination:destination userID:self.request.userID parentID:self.request.parentID fileSize:self.request.fileSize fileID:self.request.fileID hashValue:self.request.hashValue hashType:self.request.hashType driveID:self.request.driveID shareID:self.request.shareID];
        }
        @synchronized (self) {
            self.status = PDSDownloadUrlTaskStatusDownloading;
            [self processStatus];
        }
    }
}

- (void)refreshUrl {
    PDSAPIGetDownloadUrlRequest *getDownloadUrlRequest = [[PDSAPIGetDownloadUrlRequest alloc] initWithShareID:nil
                                                                                                      driveID:self.request.driveID
                                                                                                       fileID:self.request.fileID
                                                                                                     fileName:self.request.destination.lastPathComponent];
    self.getDownloadUrlTask = [self.transportClient requestSDAPIRequest:getDownloadUrlRequest];
    @weakify(self);
    [self.getDownloadUrlTask setResponseBlock:^(PDSAPIGetDownloadUrlResponse *result, PDSRequestError * _Nullable requestError) {
        @strongify(self);
        if(requestError) {
            @synchronized (self) {
                self.requestError = requestError;
                self.status = PDSDownloadUrlTaskStatusFinished;
                [self processStatus];
            }
            return;
        }
        @synchronized (self) {
            self.request = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:result.url destination:self.request.destination userID:self.request.userID parentID:self.request.parentID fileSize:result.size fileID:self.request.fileID hashValue:self.request.hashValue hashType:self.request.hashType driveID:nil shareID:nil];
            self.status = PDSDownloadUrlTaskStatusDownloading;
            [self processStatus];
        }
    } queue:self.operationQueue];
}

- (void)validate {
    if (self.request.hashType != PDSFileHashTypeNone && self.request.hashValue != nil) {//需要进行hash校验
        @synchronized (self) {
            self.hashTask = [[PDSInternalHashTask alloc] initWithFilePath:self.request.destination hashType:self.request.hashType hashValue:self.request.hashValue];
            @weakify(self);
            [self.hashTask setResponseBlock:^(BOOL success, NSString *hashResult, NSError *error) {
                @strongify(self);
                if (self == nil) {
                    return;
                }
                if (!success) {//hash校验失败
                    @synchronized (self) {
                        self.requestError = [[PDSRequestError alloc] initAsClientError:error];
                        self.status = PDSDownloadUrlTaskStatusFinished;
                        [self processStatus];
                    }
                } else {
                    @synchronized (self) {
                        self.status = PDSDownloadUrlTaskStatusFinished;
                        [self processStatus];
                    }
                }
            }];
            self.status = PDSDownloadUrlTaskStatusHashing;
            [self.hashTask resume];
        }
    } else {//不需要计算hash,直接返回
        @synchronized (self) {
            self.status = PDSDownloadUrlTaskStatusFinished;
        }
        [self processStatus];
    }
}

#pragma mark Properties

- (BOOL)isCancelled {
    @synchronized (self) {
        return self.cancelled;
    }
}

- (BOOL)isFinished {
    @synchronized (self) {
        return self.status == PDSDownloadUrlTaskStatusFinished;
    }
}


#pragma mark Set Callback

- (PDSDownloadUrlTask *)setResponseBlock:(PDSDownloadUrlResponseBlock)responseBlock {
    return [self setResponseBlock:responseBlock queue:nil];
}

- (PDSDownloadUrlTask *)setResponseBlock:(PDSDownloadUrlResponseBlock)responseBlock queue:(NSOperationQueue *)queue {
    @synchronized (self) {
        self->_responseBlock = responseBlock;
        self->_responseQueue = queue;
    }
    [self callResponseBlockIfNeeded];
    return self;
}

- (PDSDownloadUrlTask *)setProgressBlock:(PDSProgressBlock)progressBlock {
    return [self setProgressBlock:progressBlock queue:nil];
}

- (PDSDownloadUrlTask *)setProgressBlock:(PDSProgressBlock)progressBlock queue:(NSOperationQueue *)queue {
    @synchronized (self) {
        self->_progressBlock = progressBlock;
        self->_progressQueue = queue;
    }
    return self;
}

- (void)callResponseBlockIfNeeded {
    PDSDownloadUrlResponseBlock responseBlock = nil;
    NSOperationQueue *toUseQueue = nil;
    PDSRequestError *requestError = nil;
    PDSFileMetadata *resultData = nil;
    PDSDownloadUrlRequest *request = nil;
    NSString *taskIdentifier = nil;
    __block BOOL finished = nil;
    @synchronized (self) {
        toUseQueue = self->_responseQueue ?: [NSOperationQueue mainQueue];
        responseBlock = self->_responseBlock;
        requestError = self.requestError;
        resultData = self.resultData;
        request = self.request;
        taskIdentifier = self.taskIdentifier;
        finished = self.isFinished;
    }
    if (responseBlock && finished) {
        [toUseQueue addOperationWithBlock:^{
            responseBlock(resultData, requestError, request, taskIdentifier);
        }];
    }
}

@end
