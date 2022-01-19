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
#import "PDSDownloadLivePhotoTaskImpl.h"
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
#import "PDSFileMetadata.h"
#import "NSString+PDS.h"
#import "PDSDownloadUrlTaskImpl.h"
#import <extobjc/EXTScope.h>

typedef NS_ENUM(NSUInteger, PDSDownloadLivePhotoTaskStatus) {
    PDSDownloadLivePhotoTaskStatusInit,
    PDSDownloadLivePhotoTaskStatusGetDownloadUrl,
    PDSDownloadLivePhotoTaskStatusImageDownloaded,
    PDSDownloadLivePhotoTaskStatusVideoDownloaded,
    PDSDownloadLivePhotoTaskStatusFinished
};

@interface PDSDownloadLivePhotoTaskImpl ()
@property(nonatomic, assign) PDSDownloadLivePhotoTaskStatus status;
@property(nonatomic, strong) PDSDownloadTask *downloadTask;
@property(nonatomic, strong) PDSDownloadUrlRequest *downloadImageRequest;
@property(nonatomic, strong) PDSDownloadUrlRequest *downloadVideoRequest;
@property(nonatomic, strong) PDSAPIRequestTask *getDownloadUrlTask;

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
@property(nonatomic, copy) NSString *downloadImageTaskId;
@property(nonatomic, copy) NSString *downloadVideoTaskId;
@end

@implementation PDSDownloadLivePhotoTaskImpl {
    PDSDownloadResponseBlock _responseBlock;
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
    return self;
}

#pragma mark Task Actions

- (void)cancel {
    @synchronized (self) {
        self.cancelled = YES;
        [self.downloadTask cancel];
        self.downloadTask = nil;
    }
}

- (void)suspend {
    @synchronized (self) {
        self.suspended = YES;
        if (self.status == PDSDownloadLivePhotoTaskStatusGetDownloadUrl || self.status == PDSDownloadLivePhotoTaskStatusImageDownloaded) {
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
            [self _start];
        }
    }
}

- (void)start {
    [self resume];
}

- (PDSTask *)restart {
    PDSDownloadTask *task = [[PDSDownloadLivePhotoTaskImpl alloc] initWithRequest:self.request
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

- (BOOL)isFinished {
    PDSDownloadLivePhotoTaskStatus status = PDSDownloadLivePhotoTaskStatusInit;
    @synchronized (self) {
        status = self.status;
    }
    return status == PDSDownloadLivePhotoTaskStatusFinished;
}


#pragma mark Private Methods

- (void)_start {
    [self processStatus];
}

- (void)processStatus {
    PDSDownloadLivePhotoTaskStatus state = PDSDownloadLivePhotoTaskStatusInit;
    @synchronized (self) {
        state = self.status;
    }
    switch (state) {
        case PDSDownloadLivePhotoTaskStatusInit:
            [self refreshDownloadUrl];
            break;
        case PDSDownloadLivePhotoTaskStatusGetDownloadUrl:
            [self downloadImage];
            break;
        case PDSDownloadLivePhotoTaskStatusImageDownloaded:
            [self downloadVideo];
            break;
        case PDSDownloadLivePhotoTaskStatusVideoDownloaded:
            [self createFileResult];
            break;
        case PDSDownloadLivePhotoTaskStatusFinished:
            [self callResponseBlockIfNeeded];
            break;
    }
}

- (void)refreshDownloadUrl {
    PDSAPIGetDownloadUrlRequest *getDownloadUrlRequest = [[PDSAPIGetDownloadUrlRequest alloc] initWithShareID:nil
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
                self.status = PDSDownloadLivePhotoTaskStatusFinished;
                [self processStatus];
            }
            return;
        }
        @synchronized (self) {
            if (!PDSIsEmpty(result.url)) {//存在下载url，说明这个文件虽然后缀名是livep，但是实际上是个普通文件
                self.downloadImageRequest = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:result.url
                                                                                   destination:self.request.destination
                                                                                      fileSize:result.size
                                                                                        fileID:self.request.fileID
                                                                                     hashValue:self.request.hashValue
                                                                                      hashType:PDSFileHashTypeCrc64
                                                                                       driveID:self.request.driveID
                                                                                       shareID:self.request.shareID];
                self.status = PDSDownloadLivePhotoTaskStatusGetDownloadUrl;
                [self processStatus];
            } else if (!PDSIsEmpty(result.streams_info)) {//是livep资源
                [self setDownloadRequests:result];
                self.status = PDSDownloadLivePhotoTaskStatusGetDownloadUrl;
                [self processStatus];
            } else {//返回数据不对，标记为失败
                @synchronized (self) {
                    self.requestError = [[PDSRequestError alloc] initWithErrorType:PDSRequestErrorTypeUnknown
                                                                        statusCode:200
                                                                         errorCode:PDSErrorCodeCommonFormatInvalid
                                                                      errorMessage:PDSErrorCodeCommonFormatInvalidMessage
                                                                       clientError:nil];
                    self.status = PDSDownloadLivePhotoTaskStatusFinished;
                    [self processStatus];
                }
                return;
            }
        }
    }                                   queue:self.operationQueue];
}

- (void)setDownloadRequests:(PDSAPIGetDownloadUrlResponse *)response {
    [response.streams_info enumerateKeysAndObjectsUsingBlock:^(NSString *extension, NSDictionary *streamInfo, BOOL *stop) {
        NSString *fileName = [[self.request.destination.lastPathComponent stringByDeletingPathExtension] stringByAppendingPathExtension:extension];
        PDSDownloadUrlRequest *request = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:streamInfo[@"url"]
                                                                                destination:[self.request.destination stringByAppendingPathComponent:fileName]
                                                                                   fileSize:[streamInfo[@"size"] unsignedLongLongValue]
                                                                                     fileID:self.request.fileID
                                                                                  hashValue:streamInfo[@"crc64_hash"]
                                                                                   hashType:PDSFileHashTypeCrc64
                                                                                    driveID:self.request.driveID
                                                                                    shareID:self.request.shareID];

        if ([extension isEqualToString:@"mov"]) {//视频数据
            self.downloadImageTaskId = [self.taskIdentifier stringByAppendingFormat:@"-%@", @"movie"];
            self.downloadVideoRequest = request;
        } else {//图片数据
            self.downloadVideoTaskId = [self.taskIdentifier stringByAppendingFormat:@"-%@", @"image"];
            self.downloadImageRequest = request;
        }
    }];
}

- (void)downloadImage {
    @weakify(self);
    if (self.downloadTask && !self.downloadTask.isFinished && !self.downloadTask.isCancelled) {//之前存在下载任务，恢复下载
        [self.downloadTask resume];
        return;
    }
    if (!self.downloadVideoRequest) {//不存在视频，说明不是一个标准的livep资源，当作普通文件下载
        self.downloadTask = [self.transportClient requestDownload:self.downloadImageRequest taskIdentifier:self.taskIdentifier storageClient:NULL];
        [self.downloadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            @strongify(self);
            [self callProgressIfNeededWithBytesWritten:bytesWritten
                                     totalBytesWritten:totalBytesWritten
                             totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        }                             queue:self.operationQueue];
        [self.downloadTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, NSString *taskIdentifier) {
            @strongify(self);
            @synchronized (self) {
                self.requestError = requestError;
                self.resultData = result;
                self.status = PDSDownloadLivePhotoTaskStatusFinished;
                [self processStatus];
            }
        }                             queue:self.operationQueue];
        return;
    }
    if ([self checkFileExistAtPath:self.downloadImageRequest.destination size:self.downloadImageRequest.fileSize]) {//已经下载完成，直接进入下一步
        @synchronized (self) {
            self.status = PDSDownloadLivePhotoTaskStatusImageDownloaded;
            [self processStatus];
        }
        return;
    }
    self.downloadTask = [self.transportClient requestDownload:self.downloadImageRequest taskIdentifier:self.downloadImageTaskId storageClient:NULL];
    [self.downloadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        @strongify(self);
        [self callProgressIfNeededWithBytesWritten:bytesWritten
                                 totalBytesWritten:totalBytesWritten
                         totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }                             queue:self.operationQueue];
    [self.downloadTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, NSString *taskIdentifier) {
        if (requestError) {//失败直接返回
            @strongify(self);
            @synchronized (self) {
                self.requestError = requestError;
                self.status = PDSDownloadLivePhotoTaskStatusFinished;
                [self processStatus];
            }
            return;
        }
        @synchronized (self) {
            self.status = PDSDownloadLivePhotoTaskStatusImageDownloaded;
            [self processStatus];
            return;
        }
    } queue:self.operationQueue];
}

- (void)downloadVideo {
    if ([self checkFileExistAtPath:self.downloadVideoRequest.destination size:self.downloadVideoRequest.fileSize]) {//已经下载完成，直接进入下一步
        @synchronized (self) {
            self.status = PDSDownloadLivePhotoTaskStatusVideoDownloaded;
            [self processStatus];
        }
        return;
    }
    if (self.downloadTask && !self.downloadTask.isFinished && !self.downloadTask.isCancelled) {//之前存在下载任务，恢复下载
        [self.downloadTask resume];
        return;
    }
    @weakify(self);
    uint64_t totalFileSize = self.downloadImageRequest.fileSize + self.downloadVideoRequest.fileSize;
    uint64_t imageFileSize = self.downloadImageRequest.fileSize;
    self.downloadTask = [self.transportClient requestDownload:self.downloadVideoRequest taskIdentifier:self.downloadVideoTaskId storageClient:NULL];
    [self.downloadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        @strongify(self);
        [self callProgressIfNeededWithBytesWritten:bytesWritten
                                 totalBytesWritten:imageFileSize + totalBytesWritten
                         totalBytesExpectedToWrite:totalFileSize];
    }                             queue:self.operationQueue];
    [self.downloadTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, NSString *taskIdentifier) {
        if (requestError) {//失败直接返回
            @strongify(self);
            @synchronized (self) {
                self.requestError = requestError;
                self.status = PDSDownloadLivePhotoTaskStatusFinished;
                [self processStatus];
            }
            return;
        }
        @synchronized (self) {
            self.status = PDSDownloadLivePhotoTaskStatusVideoDownloaded;
            [self processStatus];
            return;
        }
    } queue:self.operationQueue];
}

- (void)createFileResult {
    @synchronized (self) {
        self.resultData = [[PDSFileMetadata alloc] initWithFileID:self.request.fileID
                                                         fileName:self.request.destination.lastPathComponent
                                                         filePath:self.request.destination
                                                          driveID:nil
                                                         uploadID:nil];
        self.status = PDSDownloadLivePhotoTaskStatusFinished;
        [self processStatus];
    }
}

- (BOOL)checkFileExistAtPath:(NSString *)filePath size:(uint64_t)size {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([fileAttributes[NSFileSize] unsignedLongLongValue] == size) {
            return YES;
        }
    }
    return NO;
}

#pragma mark Callback

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

- (void)callProgressIfNeededWithBytesWritten:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
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
}
@end