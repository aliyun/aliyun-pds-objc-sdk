//
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
  

#import "PDSUploadPhotoTaskImpl.h"
#import "PDSUploadPhotoRequest.h"
#import "PDSUploadFileRequest.h"
#import "PDSSessionDelegate.h"
#import "PDSTransportClient.h"
#import "PDSUploadFileTaskImpl.h"
#import "PDSInternalExportPhotoTask.h"
#import "PDSRequestError.h"
#import "PDSMacro.h"
#import "PDSTaskStorageClient.h"
#import <extobjc/EXTScope.h>
#import <PDSTaskStorageClient.h>

typedef NS_ENUM(NSUInteger, PDSUploadPhotoTaskStatus) {
    PDSUploadPhotoTaskStatusInit = 0,
    PDSUploadPhotoTaskStatusExported = 1,
    PDSUploadPhotoTaskStatusFinished = 10000
};

@interface PDSUploadPhotoTaskImpl ()
@property(nonatomic, weak) PDSSessionDelegate *sessionDelegate;
@property(nonatomic, weak) NSURLSession *session;
@property(nonatomic, weak) PDSTransportClient *transportClient;
@property(nonatomic, weak) PDSTaskStorageClient *storageClient;

@property(nonatomic, strong) PDSInternalExportPhotoTask *exportPhotoTask;
@property(nonatomic, strong) PDSUploadFileTaskImpl *uploadFileTask;

@property(nonatomic, strong) PDSUploadPhotoRequest *request;
@property(nonatomic, strong) PDSRequestError *requestError;
@property(nonatomic, strong) PDSFileMetadata *resultData;

@property(nonatomic, copy) NSString *exportedFilePath;
@property(nonatomic, assign) PDSUploadPhotoTaskStatus status;
@property(nonatomic, assign) BOOL cancelled;
@property(nonatomic, assign) BOOL suspended;
@property(nonatomic, assign) BOOL started;
@property(nonatomic, copy) NSString *exportedFileName;
@end

@implementation PDSUploadPhotoTaskImpl {
    PDSUploadResponseBlock _responseBlock;
    NSOperationQueue *_responseQueue;
    PDSProgressBlock _progressBlock;
    NSOperationQueue *_progressQueue;
}


- (id)initWithRequest:(PDSUploadPhotoRequest *)request identifier:(NSString *)identifier session:(NSURLSession *)session sessionDelegate:(PDSSessionDelegate *)sessionDelegate transportClient:(PDSTransportClient *)transportClient storageClient:(PDSTaskStorageClient *)storageClient {
    self = [self initWithIdentifier:identifier];
    if (self) {
        self.request = request;
        self.session = session;
        self.sessionDelegate = sessionDelegate;
        self.transportClient = transportClient;
        self.storageClient = storageClient;
        self.status = PDSUploadPhotoTaskStatusInit;
    }
    return self;
}

#pragma mark Task Control

- (void)cancel {
    @synchronized (self) {
        if (self.cancelled) {
            return;
        }
        self.cancelled = YES;
        [self.exportPhotoTask cancel];
        [self.uploadFileTask cancel];
        self.status = PDSUploadPhotoTaskStatusFinished;
    }
}

- (void)suspend {
    @synchronized (self) {
        if(self.suspended) {
            return;
        }
        self.suspended = YES;
        [self.uploadFileTask suspend];
    }
}

- (void)resume {
    @weakify(self);
    @synchronized (self) {
        if (self.isCancelled || self.isFinished) {
            return;
        }
        self.suspended = NO;
        [self _start];
    }
}

- (void)start {
    [self resume];
}

- (void)_start {
    [self processStatus];
}

- (PDSTask *)restart {
    PDSUploadTask *task = [[PDSUploadPhotoTaskImpl alloc] initWithRequest:self.request
                                                               identifier:self.taskIdentifier
                                                                  session:self.session
                                                          sessionDelegate:self.sessionDelegate
                                                          transportClient:self.transportClient
                                                            storageClient:self.storageClient];
    [task setResponseBlock:_responseBlock queue:_responseQueue];
    [task setProgressBlock:_progressBlock queue:_progressQueue];
    task.retryCount = self.retryCount + 1;
    [task resume];
    return task;
}

- (void)cleanup {
    NSString *exportedFilePath = nil;
    @synchronized (self) {
        exportedFilePath = self.exportedFilePath;
    }
    if (!PDSIsEmpty(exportedFilePath)) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:exportedFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:exportedFilePath error:nil];
        }
    }
}

#pragma mark Private Method

- (void)processStatus {
    PDSUploadPhotoTaskStatus status = PDSUploadPhotoTaskStatusInit;
    @synchronized (self) {
        status = self.status;
    }
    switch(status) {
        case PDSUploadPhotoTaskStatusInit:
            [self exportPhoto];
            break;
        case PDSUploadPhotoTaskStatusExported:
            [self startUpload];
            break;
        case PDSUploadPhotoTaskStatusFinished:
            [self callResponseBlockIfNeeded];
            [self cleanup];
            break;
    }
}

- (void)exportPhoto {
    if (self.exportPhotoTask) {
        [self.exportPhotoTask cancel];
    }
    self.exportPhotoTask = [[PDSInternalExportPhotoTask alloc] initWithPhotoLocalIdentifier:self.request.localIdentifier];
    @weakify(self);
    [self.exportPhotoTask setResponseBlock:^(BOOL success, NSString *localPath,NSString *fileName, NSError *error) {
        @strongify(self);
        if (success) {
            @synchronized (self) {
                self.exportedFilePath = localPath;
                self.exportedFileName = fileName;
                self.status = PDSUploadPhotoTaskStatusExported;
            }
        } else {
            @synchronized (self) {
                self.requestError = [[PDSRequestError alloc] initAsClientError:error];
                self.status = PDSUploadPhotoTaskStatusFinished;
            }
        }
        [self processStatus];
    }];
    [self.exportPhotoTask start];
}

- (void)startUpload {
    if (self.uploadFileTask && !self.uploadFileTask.isFinished) {
        [self.uploadFileTask resume];
        return;
    }
    NSString *fileName = PDSIsEmpty(self.request.fileName) ? self.exportedFileName : self.request.fileName;
    PDSUploadFileRequest *uploadFileRequest = [[PDSUploadFileRequest alloc] initWithUploadPath:self.exportedFilePath
                                                                                  parentFileID:self.request.parentFileID
                                                                                        fileID:self.request.fileID
                                                                                       driveID:self.request.driveID
                                                                                       shareID:self.request.shareID
                                                                                      fileName:fileName
                                                                                 checkNameMode:self.request.checkNameMode
                                                                                    shareToken:self.request.shareToken
                                                                                 sharePassword:self.request.sharePassword];
    self.uploadFileTask = [[PDSUploadFileTaskImpl alloc] initWithRequest:uploadFileRequest identifier:self.taskIdentifier session:self.session sessionDelegate:self.sessionDelegate transportClient:self.transportClient storageClient:self.storageClient];
    @weakify(self);
    [self.uploadFileTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, NSString *taskIdentifier) {
        @strongify(self);
        if (requestError) {//上传失败
            @synchronized (self) {
                self.requestError = requestError;
                self.status = PDSUploadPhotoTaskStatusFinished;
                [self callResponseBlockIfNeeded];
            }
            return;
        }
        @synchronized (self) {
            self.resultData = result;
            self.status = PDSUploadPhotoTaskStatusFinished;
            [self callResponseBlockIfNeeded];
        }
    }];
    [self.uploadFileTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        @strongify(self);
        PDSProgressBlock progressBlock;
        NSOperationQueue *progressQueue;
        @synchronized (self) {
            progressBlock = self->_progressBlock;
            progressQueue = self->_progressQueue;
        }
        if (progressBlock) {
            progressQueue = progressQueue ?: [NSOperationQueue mainQueue];
            [progressQueue addOperationWithBlock:^{
                progressBlock(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
            }];
        }
    }];
    [self.uploadFileTask resume];
}

#pragma mark Properties

- (BOOL)isFinished {
    @synchronized (self) {
        return self.status == PDSUploadPhotoTaskStatusFinished;
    }
}

- (BOOL)isCancelled {
    @synchronized (self) {
        return self.cancelled;
    }
}

- (BOOL)isSuspended {
    @synchronized (self) {
        return self.suspended;
    }
}

#pragma mark Callback

- (PDSUploadTask *)setResponseBlock:(PDSUploadResponseBlock)responseBlock {
    return [self setResponseBlock:responseBlock queue:nil];
}

- (PDSUploadTask *)setResponseBlock:(PDSUploadResponseBlock)responseBlock queue:(NSOperationQueue *)queue {
    @synchronized (self) {
        self->_responseBlock = responseBlock;
        self->_responseQueue = queue;
    }
    if (self.isFinished) {
        [self callResponseBlockIfNeeded];
    }
    return self;
}

- (PDSUploadTask *)setProgressBlock:(PDSProgressBlock)progressBlock {
    return [self setProgressBlock:progressBlock queue:nil];
}

- (PDSUploadTask *)setProgressBlock:(PDSProgressBlock)progressBlock queue:(NSOperationQueue *)queue {
    _progressBlock = progressBlock;
    _progressQueue = queue;
    __block PDSUploadFileTaskImpl *uploadTask = nil;
    @synchronized (self) {
        uploadTask = self.uploadFileTask;
    }
    if (uploadTask) {
        [uploadTask setProgressBlock:progressBlock];
    }
    return self;
}

- (void)callResponseBlockIfNeeded {
    NSOperationQueue *toUseQueue = nil;
    PDSRequestError *requestError = nil;
    PDSUploadResponseBlock responseBlock = nil;
    NSString *taskIdentifier = nil;
    PDSFileMetadata *resultData = nil;
    @synchronized (self) {
        toUseQueue = self->_responseQueue ?: [NSOperationQueue mainQueue];
        requestError = self.requestError;
        responseBlock = self->_responseBlock;
        taskIdentifier = self.taskIdentifier;
        resultData = self.resultData;
    };
    if (responseBlock) {
        [toUseQueue addOperationWithBlock:^{
            responseBlock(resultData, requestError, taskIdentifier);
        }];
    }
}

- (void)dealloc {
    [self cleanup];
}

@end
