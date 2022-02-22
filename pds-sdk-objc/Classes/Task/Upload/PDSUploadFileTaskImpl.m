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

#import <PDSTaskStorageClient.h>
#import "PDSUploadFileTaskImpl.h"
#import "PDSUploadFileRequest.h"
#import "PDSTaskFileSectionInfo.h"
#import "PDSAPIRequestTask.h"
#import "PDSAPICreateFileRequest.h"
#import "PDSTransportClient.h"
#import "PDSFileMetadata.h"
#import "PDSAPICreateFileResponse.h"
#import "PDSFileSubSection.h"
#import "PDSInternalUploadTask.h"
#import "PDSSessionDelegate.h"
#import "PDSAPICompleteFileResponse.h"
#import "PDSAPIGetUploadUrlResponse.h"
#import "PDSAPICompleteFileRequest.h"
#import "PDSAPIGetUploadUrlRequest.h"
#import "PDSAPIGetUploadUrlResponse.h"
#import "PDSInternalHashTask.h"
#import "PDSRequestError.h"
#import "PDSError.h"
#import "PDSTransportClient+Internal.h"
#import "NSArray+PDS.h"
#import "PDSLogger.h"
#import "PDSMacro.h"
#import "PDSTaskStorageClient.h"
#import "PDSUploadTaskInfoStorageContext.h"
#import "PDSFileMetadata.h"
#import "PDSClientConfig.h"
#import <extobjc/EXTScope.h>

typedef NS_ENUM(NSUInteger, PDSUploadFileTaskStatus) {
    PDSUploadFileTaskStatusInit = 0,
    PDSUploadFileTaskStatusFileCreated = 10,
    PDSUploadFileTaskStatusRefreshUploadUrl = 11,
    PDSUploadFileTaskStatusUploading = 100,
    PDSUploadFileTaskStatusUploaded = 1000,
    PDSUploadFileTaskStatusFinished = 10000
};

@interface PDSUploadFileTaskImpl () <PDSTaskFileSectionInfoDelegate>
@property(nonatomic, weak) PDSSessionDelegate *sessionDelegate;
@property(nonatomic, weak) NSURLSession *session;
@property(nonatomic, weak) PDSTransportClient *transportClient;
@property(nonatomic, weak) PDSTaskStorageClient *storageClient;
@property(nonatomic, strong) PDSTaskFileSectionInfo *sectionInfo;
@property(nonatomic, assign) NSTimeInterval previousProgressCallbackTime;

@property(nonatomic, strong) PDSAPIRequestTask<PDSAPICreateFileResponse *> *createFileTask;
@property(nonatomic, strong) PDSAPIRequestTask<PDSAPICompleteFileResponse *> *completeFileTask;
@property(nonatomic, strong) PDSAPIRequestTask<PDSAPIGetUploadUrlResponse *> *getUploadUrlTask;
@property(nonatomic, strong) PDSInternalHashTask *hashTask;
@property(nonatomic, strong) PDSInternalUploadTask *uploadFileTask;
@property(nonatomic, strong) NSOperationQueue *operationQueue;


@property(nonatomic, strong) PDSUploadFileRequest *request;
@property(nonatomic, strong) PDSRequestError *requestError;
@property(nonatomic, strong) PDSFileMetadata *resultData;
@property(nonatomic, assign) PDSUploadFileTaskStatus status;
@property(nonatomic, assign) BOOL cancelled;
@property(nonatomic, assign) BOOL started;
@property(nonatomic, assign) BOOL executing;
@end

@implementation PDSUploadFileTaskImpl {
    PDSUploadResponseBlock _responseBlock;
    NSOperationQueue *_responseQueue;
    PDSProgressBlock _progressBlock;
    NSOperationQueue *_progressQueue;
}

- (id)initWithRequest:(PDSUploadFileRequest *)request identifier:(NSString *)identifier session:(NSURLSession *)session sessionDelegate:(PDSSessionDelegate *)sessionDelegate transportClient:(PDSTransportClient *)transportClient storageClient:(PDSTaskStorageClient *)storageClient {
    self = [self initWithIdentifier:identifier];
    if (self) {
        self.request = request;
        self.session = session;
        self.sessionDelegate = sessionDelegate;
        self.transportClient = transportClient;
        self.storageClient = storageClient;
        [self setup];
    }
    return self;
}

- (void)setup {
    self.status = PDSUploadFileTaskStatusInit;
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.name = [NSString stringWithFormat:@"com.aliyun.pds.upload.%@", self.taskIdentifier];
}

#pragma mark Task Control

- (void)cancel {
    @synchronized (self) {
        if (self.cancelled) {
            return;
        }
        self.cancelled = YES;
        [self.uploadFileTask cancel];
        [self.getUploadUrlTask cancel];
        [self.completeFileTask cancel];
        [self.uploadFileTask cancel];
        [self.hashTask cancel];
        self.status = PDSUploadFileTaskStatusFinished;
    }
}

- (void)suspend {
    @synchronized (self) {
        if (!self.executing || self.isCancelled) {
            return;
        }
        self.executing = NO;
        [self.uploadFileTask cancel];
        [self.getUploadUrlTask cancel];
        [self.completeFileTask cancel];
        [self.uploadFileTask cancel];
        [self.hashTask cancel];
    }
}

- (void)resume {
    @weakify(self);
    @synchronized (self) {
        if (self.isCancelled || self.isFinished || self.executing) {
            return;
        }
        self.executing = YES;
        if (!self.started) {
            self.started = YES;
            //全新的任务，先尝试从数据库恢复状态
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
    PDSUploadTask *task = [[PDSUploadFileTaskImpl alloc] initWithRequest:self.request
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

- (void)_start {
    [self processStatus];
}

- (void)processStatus {
    PDSUploadFileTaskStatus status = PDSUploadFileTaskStatusInit;
    __block BOOL executing = NO;
    __block BOOL cancelled = NO;
    @synchronized (self) {
        executing = self.executing;
        cancelled = self.cancelled;
        status = self.status;
    }
    //统一持久化任务状态
    [self syncTaskStatus:status];

    if (cancelled || !executing) {
        return;
    }

    switch (status) {
        case PDSUploadFileTaskStatusInit:
            [PDSLogger logDebug:@"开始进行上传任务"];
            if(!self.transportClient.clientConfig.enableFastUpload) {//禁用快速上传，直接开始上传
                [self createFileTaskWithPreHash:nil fullHashValue:nil];
            } else {//启用快速上传，先计算1K的预Hash
                [self startHashTask:PDSFileHashCalculateTypeOnly1K];
            }
            break;
        case PDSUploadFileTaskStatusFileCreated:
        case PDSUploadFileTaskStatusUploading:
            //开始进行分片上传
            [PDSLogger logDebug:@"进行文件分片上传"];
            [self uploadNextSection];
            break;
        case PDSUploadFileTaskStatusRefreshUploadUrl:
            [PDSLogger logDebug:@"上传链接过期，开始刷新url"];
            [self refreshUploadUrl];
            break;
        case PDSUploadFileTaskStatusUploaded:
            //上传完成,调用完成文件接口
            [PDSLogger logDebug:@"所有分片上传完成，开始调用完成文件接口"];
            [self handleComplete];
            break;
        case PDSUploadFileTaskStatusFinished:
            [self callResponseBlockIfNeeded];
            [PDSLogger logDebug:@"文件上传流程结束"];
            break;
    }
}

- (void)startHashTask:(PDSFileHashCalculateType)hashCalculateType {
    @weakify(self);
    self.hashTask = [[PDSInternalHashTask alloc] initWithFilePath:self.request.uploadPath
                                                         hashType:PDSFileHashTypeSha1
                                                        hashValue:nil
                                                    calculateType:hashCalculateType];
    [self.hashTask start];
    [self.hashTask setResponseBlock:^(BOOL success, NSString *hashResult, NSError *error) {
        @strongify(self);
        if (!success) {//hash计算失败
            @synchronized (self) {
                self.requestError = [[PDSRequestError alloc] initAsClientError:error];
                self.status = PDSUploadFileTaskStatusFinished;
                [self processStatus];
            }
        } else {//请求创建文件接口
            if (hashCalculateType == PDSFileHashCalculateTypeFull) {
                [self createFileTaskWithPreHash:nil fullHashValue:hashResult];
            } else {
                [self createFileTaskWithPreHash:hashResult fullHashValue:nil];
            }
        }
    }];
}

- (void)createFileTaskWithPreHash:(NSString *)preHash fullHashValue:(NSString *)fullHashValue {
    PDSAPICreateFileRequest *createFileRequest = [[PDSAPICreateFileRequest alloc] initWithShareID:self.request.shareID driveID:self.request.driveID parentFileID:self.request.parentFileID fileName:self.request.fileName fileID:nil fileSize:self.request.fileSize hashValue:fullHashValue preHashValue:preHash sectionSize:self.sectionInfo.sectionSize sectionCount:self.sectionInfo.sectionCount];
    self.createFileTask = [self.transportClient requestSDAPIRequest:createFileRequest];
    @weakify(self);
    [self.createFileTask setResponseBlock:^(PDSAPICreateFileResponse *_Nullable result, PDSRequestError *_Nullable requestError) {
        @strongify(self);
        if (requestError) {
            if ([requestError.code isEqualToString:PDSErrorCodeCreateFilePreHashMatched]) {//PreHash命中，计算完整Hash
                [self startHashTask:PDSFileHashCalculateTypeFull];
                return;
            } else {
                @synchronized (self) {
                    self.requestError = requestError;
                    self.status = PDSUploadFileTaskStatusFinished;
                }
                [self processStatus];
                return;
            }
        }
        if(result.status == PDSAPICreateFileStatusFinished) {//秒传成功
            @synchronized (self) {
                self.resultData = [[PDSFileMetadata alloc] initWithFileID:result.fileId
                                                                 fileName:result.fileName
                                                                 filePath:nil
                                                                  driveID:self.request.driveID
                                                                 uploadID:nil];
                self.status = PDSUploadFileTaskStatusFinished;
                [self processStatus];
            }
        } else {//PreHash没有命中或者上传完整Hash直接创建文件接口返回成功,开始正常下载
            @synchronized (self) {
                //创建文件接口返回的信息解析完成,改变状态
                self.status = PDSUploadFileTaskStatusFileCreated;
            }
            [self updateFileSectionInfo:result.partInfoList fileID:result.fileId uploadID:result.uploadId];
            [self processStatus];
        }
    } queue:self.operationQueue];
}

/// 恢复状态
- (void)_restoreWithCompletion:(void (^)(void))completion {
    [self.storageClient getUploadTaskInfoWithId:self.taskIdentifier
                                                        completion:^(NSString *taskIdentifier, NSDictionary *taskInfo, NSArray<PDSFileSubSection *> *fileSections) {
        if (PDSIsEmpty(taskInfo) || PDSIsEmpty(fileSections)) {//没有历史任务记录，直接开始上传
            self.sectionInfo = [[PDSTaskFileSectionInfo alloc] initWithTaskIdentifier:self.taskIdentifier
                                                                             fileSize:self.request.fileSize
                                                                          sectionSize:self.request.sectionSize];
        } else {//存在历史记录进行恢复
            [PDSLogger logDebug:@"上传任务存在历史记录,进行恢复"];
            PDSUploadTaskInfoStorageContext *storageContext = [[PDSUploadTaskInfoStorageContext alloc] initWithDictionary:taskInfo];
            self.status = (PDSUploadFileTaskStatus) storageContext.status;//恢复状态，从原来的状态开始
            self.sectionInfo = [[PDSTaskFileSectionInfo alloc] initWithTaskIdentifier:taskIdentifier
                                                                             fileSize:self.request.fileSize
                                                                          sectionSize:self.request.sectionSize
                                                                               fileID:storageContext.fileId
                                                                             uploadID:storageContext.uploadId
                                                                          subSections:fileSections];
        }
        self.sectionInfo.delegate = self;
        if (completion) {
            completion();
        }
    }];
}

- (void)updateFileSectionInfo:(NSArray<PDSAPIUploadFilePartInfoItem *> *)partInfoList fileID:(NSString *)fileID uploadID:(NSString *)uploadID {
    @synchronized (self) {
        self.sectionInfo.fileID = fileID;
        self.sectionInfo.uploadID = uploadID;
        [self.sectionInfo updateSubSections:^BOOL(PDSFileSubSection *subSection) {
            PDSAPIUploadFilePartInfoItem *partInfoItem = [partInfoList pds_objectAtIndex:subSection.index];
            if (partInfoItem) {
                subSection.outputUrl = partInfoItem.uploadUrl;
                return YES;
            }
            return NO;
        }];
    }
}


- (void)uploadNextSection {
    __block PDSFileSubSection *toUploadSection = nil;
    __block BOOL executing = NO;
    __block BOOL cancelled = NO;
    __block PDSUploadFileTaskStatus status = PDSUploadFileTaskStatusInit;
    @synchronized (self) {
        executing = self.executing;
        cancelled = self.cancelled;
        toUploadSection = [self.sectionInfo getNextAvailableSection];
        status = self.status;
    }
    if (!executing || cancelled || status == PDSUploadFileTaskStatusUploaded) {
        return;
    }
    self.status = PDSUploadFileTaskStatusUploading;
    if (!toUploadSection) {//没有剩余分片需要上传
        if (self.sectionInfo.isFinished) {//全部上传完成，跳到完成阶段
            @synchronized (self) {
                self.status = PDSUploadFileTaskStatusUploaded;
                [self processStatus];
            }
            return;
        } else {//还有任务在上传，等待其他任务完成
            return;
        }
    }
    //开始上传
    @synchronized (self) {
        [PDSLogger logDebug:[NSString stringWithFormat:@"开始上传分片:%@", toUploadSection]];
        self.uploadFileTask = [[PDSInternalUploadTask alloc] initWithRequest:self.request
                                                               uploadSection:toUploadSection
                                                                     session:self.session
                                                             sessionDelegate:self.sessionDelegate];
        [self.uploadFileTask resume];
        //设置分片上传任务的完成回调
        PDSUploadResponseBlockStorage responseBlockStorage = [self storageBlockResponseWithFileSection:self.uploadFileTask.uploadSection];
        [self.sessionDelegate addUploadResponseHandlerForTaskWithIdentifier:self.uploadFileTask.identifier
                                                                    session:self.session
                                                      uploadResponseHandler:responseBlockStorage
                                                       responseHandlerQueue:_responseQueue];
        //设置分片上传任务的进度回调
        if (_progressBlock) {
            PDSProgressBlock progressBlockStorage = [self storageBlockWithProgressBlock:_progressBlock fileSection:self.uploadFileTask.uploadSection];
            [self.sessionDelegate addProgressResponseHandlerForTaskWithIdentifier:self.uploadFileTask.identifier
                                                                          session:self.session
                                                                  progressHandler:progressBlockStorage
                                                             progressHandlerQueue:_progressQueue];
        }
    }
}

#pragma mark Private Method

- (void)refreshUploadUrl {
    PDSAPIGetUploadUrlRequest *getUploadUrlRequest = [[PDSAPIGetUploadUrlRequest alloc] initWithFileID:self.sectionInfo.fileID
                                                                                              uploadID:self.sectionInfo.uploadID
                                                                                               driveID:self.request.driveID
                                                                                               shareID:self.request.shareID
                                                                                          partInfoList:[self.sectionInfo partInfoItems]
                                                                                            contentMd5:nil];
    self.getUploadUrlTask = [self.transportClient requestSDAPIRequest:getUploadUrlRequest];
    @weakify(self);
    [self.getUploadUrlTask setResponseBlock:^(PDSAPIGetUploadUrlResponse *result, PDSRequestError *_Nullable requestError) {
        @strongify(self);
        if (requestError) {
            @synchronized (self) {
                self.requestError = requestError;
                self.status = PDSUploadFileTaskStatusFinished;
                [self processStatus];
            }
            return;
        }
        @synchronized (self) {
            [self updateFileSectionInfo:result.partInfoList fileID:result.fileID uploadID:result.uploadID];
            self.status = PDSUploadFileTaskStatusUploading;
            [self processStatus];
        }
    }                                 queue:self.operationQueue];
}

- (void)handleComplete {
    PDSUploadFileTaskStatus status = PDSUploadFileTaskStatusInit;
    @synchronized (self) {
        status = self.status;
    }
    if (status != PDSUploadFileTaskStatusUploaded) {
        return;
    }
    //所有文件分片上传完成，调用完成接口
    __block NSString *uploadID = nil;
    __block NSString *fileID = nil;
    @synchronized (self) {
        uploadID = self.sectionInfo.uploadID;
        fileID = self.sectionInfo.fileID;
    }
    @weakify(self);
    PDSAPICompleteFileRequest *completeFileRequest = [[PDSAPICompleteFileRequest alloc] initWithShareID:self.request.shareID
                                                                                                driveID:self.request.driveID
                                                                                                 fileID:fileID
                                                                                               uploadID:uploadID
                                                                                           parentFileID:self.request.parentFileID
                                                                                               fileName:self.request.fileName
                                                                                            contentType:self.request.contentType];
    self.completeFileTask = [[self.transportClient requestSDAPIRequest:completeFileRequest] setResponseBlock:^(PDSAPICompleteFileResponse *result, PDSRequestError *_Nullable requestError) {
        @strongify(self);
        if (!self) {
            return;
        }
        @synchronized (self) {
            self.requestError = requestError;
            if (!requestError) {
                self.resultData = [[PDSFileMetadata alloc] initWithFileID:fileID
                                                                 fileName:self.request.fileName
                                                                 filePath:nil
                                                                  driveID:self.request.driveID
                                                                 uploadID:uploadID];
            }
            self.status = PDSUploadFileTaskStatusFinished;
        }
        [self processStatus];
    }                                                                                                  queue:self.operationQueue];
};

#pragma mark State

- (BOOL)isCancelled {
    __block BOOL isCancelled = NO;
    @synchronized (self) {
        isCancelled = self.cancelled;
    }
    return isCancelled;
}

- (BOOL)isFinished {
    @synchronized (self) {
        return self.status == PDSUploadFileTaskStatusFinished;
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
    __block PDSInternalUploadTask *uploadTask = nil;
    @synchronized (self) {
        uploadTask = self.uploadFileTask;
    }
    if (uploadTask) {
        PDSProgressBlock progressBlockStorage = [self storageBlockWithProgressBlock:progressBlock fileSection:uploadTask.uploadSection];
        [self.sessionDelegate addProgressResponseHandlerForTaskWithIdentifier:uploadTask.identifier
                                                                      session:self.session
                                                              progressHandler:progressBlockStorage
                                                         progressHandlerQueue:queue];
    }
    return self;
}

- (PDSUploadResponseBlockStorage)storageBlockResponseWithFileSection:(PDSFileSubSection *)subSection {
    __weak PDSUploadTask *weakSelf = self;
    __weak PDSTaskFileSectionInfo *fileSectionInfo = self.sectionInfo;
    PDSUploadResponseBlockStorage storageBlock = ^BOOL(NSData *data, NSURLResponse *response, NSError *error) {
        PDSUploadTask *strongSelf = weakSelf;
        if (strongSelf == nil) {
            return NO;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        int statusCode = (int) httpResponse.statusCode;
        NSDictionary *httpHeaders = httpResponse.allHeaderFields;

        BOOL successful = NO;
        PDSRequestError *requestError = [PDSTransportClient requestErrorWithErrorData:data
                                                                          clientError:error
                                                                           statusCode:statusCode
                                                                          httpHeaders:httpHeaders];
        //下载完成
        if (!requestError || requestError.statusCode == 409) {//对应分片上传完成
            //409表示对应的分片已经上传,直接标志成功，进行下一个分片上传
            subSection.committed = subSection.size;
            subSection.confirmed = YES;
            successful = YES;
            [fileSectionInfo updateSubSection:subSection];
        } else {//这个分片上传失败了，上传进度重置,标记失败
            subSection.committed = 0;
            subSection.confirmed = NO;
            [fileSectionInfo updateSubSection:subSection];
            if (error.code == NSURLErrorCancelled) {//用户主动取消回调，不进行回调
                return NO;
            }
            @synchronized (self) {
                if (requestError.statusCode == 403) {//上传链接失效，刷新链接
                    self.status = PDSUploadFileTaskStatusRefreshUploadUrl;
                } else {
                    self.requestError = requestError;
                    self.status = PDSUploadFileTaskStatusFinished;
                }
                [self processStatus];
                return NO;
            }
        }

        @synchronized (self) {
            if (fileSectionInfo.isFinished && self.status == PDSUploadFileTaskStatusUploading) {//所有分片全部上传完成,通知外部
                self.status = PDSUploadFileTaskStatusUploaded;
                [self processStatus];
            } else {//没有下完，下载下一个分片
                [self uploadNextSection];
            }
        }
        return successful;
    };
    return storageBlock;
}

/**
 * 将单个分片的进度转换成整体文件上传的进度
 * @param progressBlock 整体的文件上传进度
 * @param section 对应的分片信息
 * @return  单个文件分片上传的进度
 */
- (PDSProgressBlock)storageBlockWithProgressBlock:(PDSProgressBlock)progressBlock fileSection:(PDSFileSubSection *)section {
    __weak PDSUploadTask *weakSelf = self;
    __weak PDSTaskFileSectionInfo *fileSectionInfo = self.sectionInfo;
    PDSProgressBlock progressBlockStorage = ^(int64_t sectionBytesWritten, int64_t totalSectionBytesWritten, int64_t totalSectionBytesExpectedToWrite) {
        PDSUploadTask *strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        if (self.previousProgressCallbackTime !=0 &&
                ((currentTime - self.previousProgressCallbackTime ) < 0.06)) {//如果距离上一次回调时间不超过60ms
            return;
        }
        self.previousProgressCallbackTime = currentTime;
        section.committed = (uint64_t) totalSectionBytesWritten;
        [fileSectionInfo updateSubSection:section];
        if (progressBlock) {
            progressBlock(sectionBytesWritten, fileSectionInfo.committed, fileSectionInfo.fileSize);
        }
        return;
    };
    return progressBlockStorage;
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

#pragma mark PDSTaskFileSectionInfoDelegate

- (void)fileSubSectionsChanged:(NSArray<PDSFileSubSection *> *)fileSections forFileSectionInfo:(PDSTaskFileSectionInfo *)fileSectionInfo {
    if(fileSections.count == self.sectionInfo.sectionCount) {//这是一次全量更新，需要记录任务信息
        PDSUploadTaskInfoStorageContext *context = [[PDSUploadTaskInfoStorageContext alloc] initWithTaskIdentifier:self.taskIdentifier
                                                                                                          uploadID:fileSectionInfo.uploadID
                                                                                                            fileID:fileSectionInfo.fileID
                                                                                                              path:self.request.relativeUploadPath
                                                                                                       sectionSize:fileSectionInfo.sectionSize
                                                                                                            status:self.status];
        [self.storageClient setFileSubSections:fileSections uploadTaskInfo:context];
    }
    else {//增量更新，只需要更新分片记录就行了
        [self.storageClient setFileSubSections:fileSections forTaskIdentifier:self.taskIdentifier];
    }
}

#pragma mark Storage
- (void)syncTaskStatus:(PDSUploadFileTaskStatus)status {
    @synchronized (self) {
        PDSUploadTaskInfoStorageContext *context = [[PDSUploadTaskInfoStorageContext alloc] initWithTaskIdentifier:self.taskIdentifier
                                                                                                          uploadID:self.sectionInfo.uploadID
                                                                                                            fileID:self.sectionInfo.fileID
                                                                                                              path:self.request.relativeUploadPath
                                                                                                       sectionSize:self.sectionInfo.sectionSize
                                                                                                            status:status];
        [self.storageClient setFileSubSections:nil uploadTaskInfo:context];
    }
}

@end
