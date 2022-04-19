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
#import "PDSTaskStorageClient.h"
#import "PDSAPIGetDownloadUrlRequest.h"
#import "PDSAPIGetDownloadUrlResponse.h"
#import "PDSAPIRequestTask.h"
#import "PDSMacro.h"
#import "PDSFileMetadata.h"
#import "NSString+PDS.h"
#import <extobjc/EXTScope.h>
#import "PDSTaskStorageClient.h"

typedef NS_ENUM(NSUInteger, PDSDownloadUrlTaskStatus) {
    PDSDownloadUrlTaskStatusInit = 0,
    PDSDownloadUrlTaskStatusRefreshUrl = 2,
    PDSDownloadUrlTaskStatusDownloading = 10,
    PDSDownloadUrlTaskStatusDownloaded = 11,
    PDSDownloadUrlTaskStatusHashing = 100,//正在校验
    PDSDownloadUrlTaskStatusChecked = 101,//文件校验成功
    PDSDownloadUrlTaskStatusFinished = 1000
};

static const int kPDSDownloadTaskMaxFailRetryCount = 3;

static const int kMaxRenameCount = 10;

static const int MAX_PDS_FILE_NAME_LENGTH = 64;

@interface PDSDownloadUrlTaskImpl ()
@property(nonatomic, assign) PDSDownloadUrlTaskStatus status;
@property(nonatomic, strong) PDSInternalParallelDownloadTask *downloadTask;
@property(nonatomic, strong) PDSAPIRequestTask *getDownloadUrlTask;
@property(nonatomic, strong) PDSInternalHashTask *hashTask;
@property(nonatomic, weak) PDSSessionDelegate *sessionDelegate;
@property(nonatomic, weak) NSURLSession *session;
@property(nonatomic, weak) PDSTransportClient *transportClient;
@property(nonatomic, weak) PDSTaskStorageClient *storageClient;
@property(nonatomic, strong) PDSDownloadUrlRequest *request;
@property(nonatomic, strong) PDSRequestError *requestError;
@property(nonatomic, strong) PDSFileMetadata *resultData;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, assign) BOOL cancelled;
@property(nonatomic, assign) BOOL executing;
@property(nonatomic, assign) BOOL started;
@end

@implementation PDSDownloadUrlTaskImpl {
    PDSDownloadResponseBlock _responseBlock;
    NSOperationQueue *_responseQueue;
    PDSProgressBlock _progressBlock;
    NSOperationQueue *_progressQueue;
}

- (id)initWithRequest:(PDSDownloadUrlRequest *)request identifier:(NSString *)identifier session:(NSURLSession *)session sessionDelegate:(PDSSessionDelegate *)sessionDelegate transportClient:(PDSTransportClient *)transportClient storageClient:(PDSTaskStorageClient *)storageClient {
    self = [self initWithIdentifier:identifier];
    self.request = request;
    self.session = session;
    self.sessionDelegate = sessionDelegate;
    self.transportClient = transportClient;
    self.storageClient = storageClient;
    [self setup];
    return self;
}


- (void)setup {
    self.status = PDSDownloadUrlTaskStatusInit;
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.name = [NSString stringWithFormat:@"com.aliyun.pds.download.%@", self.taskIdentifier];
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
        if (!self.executing || self.cancelled) {
            return;
        }
        self.executing = NO;
        if (self.hashTask) {
            [self.hashTask cancel];
            self.hashTask = nil;
        }
        if (self.downloadTask) {
            [self.downloadTask suspend];
        }
    }
}

- (void)resume {
    @weakify(self);
    @synchronized (self) {
        if (self.cancelled || self.isFinished || self.executing) {
            return;
        }
        self.executing = YES;
        if (!self.started) {//全新的任务
            self.started = YES;
        }
        [self _start];
    }
}

- (void)start {
    [self resume];
}

- (PDSTask *)restart {
    PDSDownloadTask *task = [[PDSDownloadUrlTaskImpl alloc] initWithRequest:self.request identifier:self.taskIdentifier session:self.session sessionDelegate:self.sessionDelegate transportClient:self.transportClient storageClient:self.storageClient];
    [task setResponseBlock:_responseBlock queue:_responseQueue];
    [task setProgressBlock:_progressBlock queue:_progressQueue];
    task.retryCount = self.retryCount + 1;
    [task resume];
    return task;
}

#pragma mark Private Method

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
            [self refreshDownloadUrl];
            break;
        case PDSDownloadUrlTaskStatusDownloading:
            [self startDownload];
            break;
        case PDSDownloadUrlTaskStatusDownloaded:
        case PDSDownloadUrlTaskStatusHashing:
            [self checkFileHash];
            break;
        case PDSDownloadUrlTaskStatusChecked:
            [self prepareFile];
            break;
        case PDSDownloadUrlTaskStatusFinished:
            [self callResponseBlockIfNeeded];
            break;
    }
}

- (void)prepareEnv {
    NSError *error = nil;
    BOOL validated = [self validate:&error];
    if (!validated) {//校验失败，磁盘空间不够、文件名过长等等
        @synchronized (self) {
            self.requestError = [[PDSRequestError alloc] initAsClientError:error];
            self.status = PDSDownloadUrlTaskStatusFinished;
        }
        [self processStatus];
        return;
    }
    @synchronized (self) {
        self.status = PDSDownloadUrlTaskStatusDownloading;
        [self processStatus];
    }
}

- (void)startDownload {
    //如果传入的下载链接为空，尝试通过fileID重新获取下载链接
    if(PDSIsEmpty(self.request.downloadUrl)) {
        @synchronized (self) {
            self.status = PDSDownloadUrlTaskStatusRefreshUrl;
            [self processStatus];
        }
        return;
    }

    //初始化下载任务
    if (!self.downloadTask || self.downloadTask.finished) {
        //这里使用临时文件进行下载，避免命名冲突
        PDSDownloadUrlRequest *request = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:self.request.downloadUrl
                                                                                destination:self.tempDestination
                                                                                   fileSize:self.request.fileSize
                                                                                     fileID:self.request.fileID
                                                                                  hashValue:self.request.hashValue
                                                                                   hashType:self.request.hashType
                                                                                    driveID:self.request.driveID
                                                                                    shareID:self.request.shareID];
        self.downloadTask = [[PDSInternalParallelDownloadTask alloc] initWithRequest:request
                                                                          identifier:self.taskIdentifier
                                                                             session:self.session
                                                                     sessionDelegate:self.sessionDelegate
                                                                       storageClient:self.storageClient];
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
                if (networkError.statusCode == 403) {// 下载链接过期，需要重新刷新
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
        }                             queue:self.operationQueue];
    }
    [self.downloadTask resume];
}

- (BOOL)validate:(NSError **)error {
    //如果文件名过长，截断一下
    NSString *fileName = [[self.request.destination lastPathComponent] stringByDeletingPathExtension];
    if(fileName.length > MAX_PDS_FILE_NAME_LENGTH) {
        NSString *newFileName = [[fileName substringToIndex:MAX_PDS_FILE_NAME_LENGTH] stringByAppendingString:@"..."];
        NSString *newDestination = [self.request.destination stringByReplacingOccurrencesOfString:fileName withString:newFileName];
        self.request = [self.request requestWithNewDestination:newDestination];
    }

    //进行其他验证
    NSError *theError = nil;
    PDSTaskFolderExistValidator *folderExistValidator = [PDSTaskFolderExistValidator validatorWithFolderPath:
                                                                                             [self.request.destination stringByDeletingLastPathComponent]];
    PDSTaskDiskCapacityValidator *diskCapacityValidator = [PDSTaskDiskCapacityValidator validatorWithSize:self.request.fileSize];
    NSArray *validators = @[
            folderExistValidator,
            diskCapacityValidator];
    BOOL validated = [PDSTaskValidatorChecker passValidators:validators error:&theError];
    if (theError) {
        *error = theError;
    }
    return validated;
}

- (void)prepareFile {
    //处理文件名
    NSString *destination = self.request.destination;
    BOOL isNameOK = [[NSFileManager defaultManager] pds_autoRenameFile:&destination];
    if (!isNameOK) {
        // 重命名失败
        NSError *error = [NSError pds_errorWithCode:PDSErrorFileNameConflict];
        @synchronized (self) {
            self.requestError = [[PDSRequestError alloc] initAsClientError:error];
            self.status = PDSDownloadUrlTaskStatusFinished;
            [self callResponseBlockIfNeeded];
            return;
        }
    }
    @synchronized (self) {
        //移动临时下载文件到目标文件路径
        NSError *moveFileError = nil;
        [[NSFileManager defaultManager] moveItemAtPath:self.tempDestination toPath:destination error:&moveFileError];
        if (moveFileError) {
            self.requestError = [[PDSRequestError alloc] initAsClientError:moveFileError];
            self.status = PDSDownloadUrlTaskStatusFinished;
            [self processStatus];
            return;
        }
        self.resultData = [[PDSFileMetadata alloc] initWithFileID:self.request.fileID
                                                         fileName:[destination lastPathComponent]
                                                         filePath:destination
                                                          driveID:self.request.driveID
                                                         uploadID:nil];
        self.status = PDSDownloadUrlTaskStatusFinished;
        [self processStatus];
    }
}

- (void)refreshDownloadUrl {
    PDSAPIGetDownloadUrlRequest *getDownloadUrlRequest = [[PDSAPIGetDownloadUrlRequest alloc] initWithShareID:self.request.shareID
                                                                                                      driveID:self.request.driveID
                                                                                                       fileID:self.request.fileID
                                                                                                     fileName:self.request.destination.lastPathComponent];
    self.getDownloadUrlTask = [self.transportClient requestSDAPIRequest:getDownloadUrlRequest];
    @weakify(self);
    [self.getDownloadUrlTask setResponseBlock:^(PDSAPIGetDownloadUrlResponse *result, PDSRequestError *_Nullable requestError) {
        @strongify(self);
        if (requestError) {
            @synchronized (self) {
                self.requestError = requestError;
                self.status = PDSDownloadUrlTaskStatusFinished;
                [self processStatus];
            }
            return;
        }
        @synchronized (self) {
            self.request = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:result.url destination:self.request.destination fileSize:result.size fileID:self.request.fileID hashValue:self.request.hashValue hashType:self.request.hashType driveID:self.request.driveID shareID:self.request.driveID];
            self.status = PDSDownloadUrlTaskStatusDownloading;
            [self processStatus];
        }
    }                                   queue:self.operationQueue];
}

- (void)checkFileHash {
    if (self.request.hashType != PDSFileHashTypeNone && self.request.hashValue != nil) {//需要进行hash校验
        @synchronized (self) {
            NSString *hashValue = self.request.hashValue;
            if (self.request.hashType == PDSFileHashTypeCrc64) {//由于服务端接口返回的crc64是十进制的，本地校验算出来的是十六进制的，因此这里做个转换
                hashValue = [self.request.hashValue pds_decimalToHexWithCompleteLength:16];
            }
            self.hashTask = [[PDSInternalHashTask alloc] initWithFilePath:self.tempDestination hashType:self.request.hashType hashValue:hashValue];
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
                } else {//hash校验成功
                    @synchronized (self) {
                        self.status = PDSDownloadUrlTaskStatusChecked;
                        [self processStatus];
                    }
                }
            }];
            self.status = PDSDownloadUrlTaskStatusHashing;
            [self.hashTask resume];
        }
    } else {//不需要计算hash,直接返回
        @synchronized (self) {
            self.status = PDSDownloadUrlTaskStatusChecked;
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

- (NSString *)tempDestination {
    @synchronized (self) {
        if (self.request.destination) {
            return [self.request.destination stringByAppendingPathExtension:[NSString stringWithFormat:@"%@.tmp",self.taskIdentifier]];
        }
        return nil;
    }
}

#pragma mark Set Callback

- (PDSDownloadTask *)setResponseBlock:(PDSDownloadResponseBlock)responseBlock {
    return [self setResponseBlock:responseBlock queue:nil];
}

- (PDSDownloadTask *)setResponseBlock:(PDSDownloadResponseBlock)responseBlock queue:(NSOperationQueue *)queue {
    @synchronized (self) {
        self->_responseBlock = responseBlock;
        self->_responseQueue = queue;
    }
    [self callResponseBlockIfNeeded];
    return self;
}

- (PDSDownloadTask *)setProgressBlock:(PDSProgressBlock)progressBlock {
    return [self setProgressBlock:progressBlock queue:nil];
}

- (PDSDownloadTask *)setProgressBlock:(PDSProgressBlock)progressBlock queue:(NSOperationQueue *)queue {
    @synchronized (self) {
        self->_progressBlock = progressBlock;
        self->_progressQueue = queue;
    }
    return self;
}

- (void)callResponseBlockIfNeeded {
    PDSDownloadResponseBlock responseBlock = nil;
    NSOperationQueue *toUseQueue = nil;
    PDSRequestError *requestError = nil;
    PDSFileMetadata *resultData = nil;
    NSString *taskIdentifier = nil;
    __block BOOL finished = nil;
    @synchronized (self) {
        toUseQueue = self->_responseQueue ?: [NSOperationQueue mainQueue];
        responseBlock = self->_responseBlock;
        requestError = self.requestError;
        resultData = self.resultData;
        taskIdentifier = self.taskIdentifier;
        finished = self.isFinished;
    }
    if (responseBlock && finished) {
        [toUseQueue addOperationWithBlock:^{
            responseBlock(resultData, requestError, taskIdentifier);
        }];
    }
}

@end
