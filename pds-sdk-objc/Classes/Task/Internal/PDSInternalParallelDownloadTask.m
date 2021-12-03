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

#import "PDSInternalParallelDownloadTask.h"
#import "PDSDownloadUrlRequest.h"
#import "PDSFileSubSection.h"
#import "PDSSessionDelegate.h"
#import "PDSInternalParallelSubDownloadTask.h"
#import "PDSRequestError.h"
#import "PDSTaskFileSectionInfo.h"
#import "PDSLogger.h"
#import "PDSError.h"
#import <extobjc/EXTScope.h>

//分片下载每片大小
static NSInteger const kSDDownloadSectionSize = 4 * 1000 * 1000;
//最大子线程数
static NSInteger const kSDDownloadSubDownloadTaskCount = 3;

typedef NS_ENUM(NSUInteger, SDInternalParallelDownloadTaskStatus) {
    SDInternalParallelDownloadTaskStatusInit,
    SDInternalParallelDownloadTaskStatusDownloading,
    SDInternalParallelDownloadTaskStatusFinished
};

@interface PDSInternalParallelDownloadTask ()
@property(nonatomic, copy) NSString *taskIdentifier;//外部的下载任务ID
@property(nonatomic, strong) PDSDownloadUrlRequest *request;
@property(nonatomic, strong) NSMutableArray<PDSInternalParallelSubDownloadTask *> *subDownloadTasks;//分片下载的任务
@property(nonatomic, assign) SDInternalParallelDownloadTaskStatus status;
@property(nonatomic, strong) PDSTaskFileSectionInfo *sectionInfo;
@property(nonatomic, weak) PDSSessionDelegate *sessionDelegate;
@property(nonatomic, weak) NSURLSession *session;
@property(nonatomic, strong) PDSRequestError *requestError;
@property(nonatomic, assign) BOOL cancelled;
@property(nonatomic, assign) BOOL suspended;
@property(nonatomic, assign) BOOL started;
@end

@implementation PDSInternalParallelDownloadTask {
    PDSProgressBlock _progressBlock;
    NSOperationQueue *_progressBlockQueue;
    PDSInternalParallelDownloadTaskResponseBlock _responseBlock;
    NSOperationQueue *_responseBlockQueue;
}
- (id)initWithRequest:(PDSDownloadUrlRequest *)request identifier:(NSString *)identifier session:(NSURLSession *)session sessionDelegate:(PDSSessionDelegate *)sessionDelegate {
    self = [self init];
    self.request = request;
    self.taskIdentifier = identifier;
    self.session = session;
    self.sessionDelegate = sessionDelegate;
    self.status = SDInternalParallelDownloadTaskStatusInit;
    self.subDownloadTasks = [[NSMutableArray alloc] init];
    return self;
}


#pragma mark State Change

- (void)cancel {
    @synchronized (self) {
        if (self.cancelled) {
            return;
        }
        self.cancelled = YES;
        [self cancelDownloadingTasks];
    }
}

- (void)suspend {
    @synchronized (self) {
        if (self.suspended || self.cancelled) {
            return;
        }
        [self _suspend];
    }
}

- (void)resume {
    @synchronized (self) {
        if (self.started || self.cancelled) {
            return;
        }
        self.started = YES;
        self.suspended = NO;
        [self _start];
    }
}

- (void)start {
    [self resume];
}

- (id <PDSInternalTask>)restart {
    @synchronized (self) {
        PDSInternalParallelDownloadTask *task = [[PDSInternalParallelDownloadTask alloc] initWithRequest:self.request
                                                                                            identifier:self.taskIdentifier
                                                                                               session:self.session
                                                                                       sessionDelegate:self.sessionDelegate];
        task.retryCount = self.retryCount + 1;
        [task setProgressBlock:_progressBlock queue:_progressBlockQueue];
        [task setResponseBlock:_responseBlock queue:_responseBlockQueue];
        [task resume];
        return task;
    }
}

#pragma mark Private Method

- (void)_start {
    @synchronized (self) {
        if (self.status == SDInternalParallelDownloadTaskStatusInit) {
            self.sectionInfo = [[PDSTaskFileSectionInfo alloc] initWithTaskIdentifier:self.taskIdentifier
                                                                            fileSize:self.request.fileSize
                                                                         sectionSize:kSDDownloadSectionSize];
            self.status = SDInternalParallelDownloadTaskStatusDownloading;
            if (self.sectionInfo.isFinished) {//已经下载完成，直接调用
                self.status = SDInternalParallelDownloadTaskStatusFinished;
                [self callResponseBlockIfNeeded];
                return;
            }
            [self startSubDownloadTasks];
        }
    }
}

- (void)_suspend {
    [self cancelDownloadingTasks];
}

- (void)cancelDownloadingTasks {
    @synchronized (self) {
        [self.subDownloadTasks enumerateObjectsUsingBlock:^(PDSInternalParallelSubDownloadTask *subDownloadTask, NSUInteger idx, BOOL *stop) {
            [subDownloadTask cancel];
        }];
        [self.subDownloadTasks removeAllObjects];
    }
}

- (void)startSubDownloadTasks {
    @synchronized (self) {
        if (self.subDownloadTasks.count == kSDDownloadSubDownloadTaskCount || self.cancelled) {//已经到达当前最多下载的子任务数量
            return;
        }
        NSArray *toDownloadSections = [self.sectionInfo getNextAvailableSections:kSDDownloadSubDownloadTaskCount];
        if (!toDownloadSections.count) {//没有要下载的部分，全部下载完成了
            @synchronized (self) {
                self.status = SDInternalParallelDownloadTaskStatusFinished;
            }
            [self callResponseBlockIfNeeded];
            return;
        }
        [toDownloadSections enumerateObjectsUsingBlock:^(PDSFileSubSection *fileSubSection, NSUInteger idx, BOOL *stop) {
            if (fileSubSection.isFinished) {
                return;
            }
            if ([self isSubSectionDownloading:fileSubSection]) {
                return;
            }
            PDSInternalParallelSubDownloadTask *subDownloadTask = [[PDSInternalParallelSubDownloadTask alloc] initWithRequest:self.request
                                                                                                        downloadFileSection:fileSubSection
                                                                                                                    session:self.session
                                                                                                            sessionDelegate:self.sessionDelegate];
            [PDSLogger logDebug:[NSString stringWithFormat:@"准备下载的分片index:%ld",fileSubSection.index]];
            __weak PDSInternalParallelSubDownloadTask *weakSubDownloadTask = subDownloadTask;
            @weakify(self);
            [self.sessionDelegate addDownloadResponseHandlerForTaskWithIdentifier:subDownloadTask.identifier
                                                                          session:self.session
                                                          downloadResponseHandler:^(NSURL *url, NSHTTPURLResponse *response, NSError *error) {
                @strongify(self);
                if(error || response.statusCode >= 300) {
                    if(error.code == NSURLErrorCancelled) {//用户主动取消回调，不管
                        return;
                    }
                    @synchronized (self) {
                        //当并发下载中的一个下载子任务失败以后取消所有其他所有下载子任务，并返回失败
                        if(self.finished) {
                            return;
                        }
                        [self cancelDownloadingTasks];
                        if(error) {
                            self.requestError = [[PDSRequestError alloc] initAsClientError:error];
                        }
                        else {
                            self.requestError = [[PDSRequestError alloc] initWithErrorType:PDSRequestErrorTypeUnknown
                                                                                statusCode:response.statusCode
                                                                                 errorCode:PDSErrorCodeCommonUnknown
                                                                              errorMessage:PDSErrorCodeCommonUnknownMessage
                                                                               clientError:nil];
                        }
                        self.status = SDInternalParallelDownloadTaskStatusFinished;
                        [self callResponseBlockIfNeeded];
                    }
                }
                else {//下载完成
                    subDownloadTask.fileSection.confirmed = YES;
                    @synchronized (self) {
                        [self.sectionInfo updateSubSection:subDownloadTask.fileSection];
                        [self removeSubTask:subDownloadTask.identifier];
                        [self startSubDownloadTasks];//开始下载新任务
                    }
                }
            }
                                                             responseHandlerQueue:nil];
            [subDownloadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSUInteger subDownloadTaskIdentifier) {
                @strongify(self);
                if (!self) {
                    return;
                }
                @synchronized (self) {
                    if (self->_progressBlock) {
                        NSOperationQueue *toUseQueue = self->_progressBlockQueue ?: [NSOperationQueue mainQueue];
                        //这里fileSection的committed是subDownloadTask内部进行修改的
                        [self.sectionInfo updateSubSection:weakSubDownloadTask.fileSection];
                        [toUseQueue addOperationWithBlock:^{
                            self->_progressBlock(bytesWritten, self.sectionInfo.committed, self.sectionInfo.fileSize);
                        }];
                    }
                }
            }];
            @synchronized (self) {
                [self.subDownloadTasks addObject:subDownloadTask];
            }
            [subDownloadTask resume];
        }];
    }
}

- (BOOL)isSubSectionDownloading:(PDSFileSubSection *)section {
    if (!section) {
        return NO;
    }
    __block BOOL isDownloading = NO;
    @synchronized (self) {
        [self.subDownloadTasks enumerateObjectsUsingBlock:^(PDSInternalParallelSubDownloadTask *_Nonnull subDownloadTask, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([subDownloadTask.fileSection.identifier isEqualToString:section.identifier]) {//已经在下载了
                isDownloading = YES;
                *stop = YES;
            }
        }];
    }
    return isDownloading;
}

/**
 * 下载完成统一回调
 */
- (void)callResponseBlockIfNeeded {
    __block PDSInternalParallelDownloadTaskResponseBlock responseBlock = nil;
    __block NSOperationQueue *queue = nil;
    __block BOOL finished = NO;
    @synchronized (self) {
        responseBlock = self->_responseBlock;
        queue = self->_responseBlockQueue ?: [NSOperationQueue mainQueue];
        finished = self.finished;
    }
    if (finished && responseBlock) {
        [queue addOperationWithBlock:^{
            responseBlock(finished, self.requestError);
        }];
    }
}

#pragma mark Properties

- (BOOL)finished {
    @synchronized (self) {
        return self.status == SDInternalParallelDownloadTaskStatusFinished;
    }
}


#pragma mark Task Manange

- (void)removeSubTask:(NSUInteger)taskIdentifier {
    if (taskIdentifier == 0) {
        return;
    }
    @synchronized (self) {
        [self.subDownloadTasks removeObject:[self getSubTaskByIdentifier:taskIdentifier]];
    }
}

- (PDSInternalParallelSubDownloadTask *)getSubTaskByIdentifier:(NSUInteger)taskIdentifier {
    if (taskIdentifier == 0) {
        return nil;
    }
    __block PDSInternalParallelSubDownloadTask *foundTask = nil;
    @synchronized (self) {
        NSUInteger foundIndex = [self.subDownloadTasks indexOfObjectPassingTest:^BOOL(PDSInternalParallelSubDownloadTask *subDownloadTask, NSUInteger idx, BOOL *stop) {
            return subDownloadTask.identifier == taskIdentifier;
        }];
        if (foundIndex != NSNotFound) {
            foundTask = self.subDownloadTasks[foundIndex];
        }
    }
    return foundTask;
}

#pragma mark Callback

- (void)setResponseBlock:(PDSInternalParallelDownloadTaskResponseBlock)responseBlock {
    [self setResponseBlock:responseBlock queue:nil];
}

- (void)setResponseBlock:(PDSInternalParallelDownloadTaskResponseBlock)responseBlock queue:(NSOperationQueue *)queue {
    @synchronized (self) {
        self->_responseBlock = responseBlock;
        self->_responseBlockQueue = queue;
        [self callResponseBlockIfNeeded];
    }
}

- (void)setProgressBlock:(PDSProgressBlock)progressBlock {
    [self setProgressBlock:progressBlock queue:nil];
}

- (void)setProgressBlock:(PDSProgressBlock)progressBlock queue:(NSOperationQueue *)queue {
    @synchronized (self) {
        self->_progressBlock = progressBlock;
        self->_progressBlockQueue = queue;
    }
}

@end
