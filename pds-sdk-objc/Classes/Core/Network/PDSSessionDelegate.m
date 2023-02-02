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

#import "PDSSessionDelegate.h"
#import "PDSSessionData.h"
#import "PDSSDKConstants.h"
#import "PDSCompletionData.h"
#import "PDSInternalTypes.h"
#import "PDSProgressData.h"

@interface PDSSessionDelegate ()
@property(nonatomic, strong) NSMutableDictionary<NSString *, PDSSessionData *> *sessionData;
@property(nonatomic, strong) NSOperationQueue *delegateQueue;;
@end

@implementation PDSSessionDelegate {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }

    return self;
}

- (void)setup {
    self.sessionData = [[NSMutableDictionary alloc] init];
    self.delegateQueue = [[NSOperationQueue alloc] init];
    self.delegateQueue.maxConcurrentOperationCount = 1;
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    PDSSessionData *sessionData = [self sessionDataWithSession:session];
    NSNumber *taskId = @(dataTask.taskIdentifier);
    PDSDownloadDataReceivedBlock downloadDataReceivedHandler = sessionData.dataReceiveHandlers[taskId];
    if (downloadDataReceivedHandler) {//对于下载任务，我们直接让handler处理接收的数据
        NSOperationQueue *queueToUse = sessionData.dataReceiveHandlersQueues[taskId] ?: [NSOperationQueue mainQueue];
        [queueToUse addOperationWithBlock:^{
            downloadDataReceivedHandler(data, dataTask);
        }];
    } else {//对于普通任务，我们把数据存起来，之后进行解析(JSON/XML)
        if (sessionData.responsesData[taskId]) {
            [sessionData.responsesData[taskId] appendData:data];
        } else {
            sessionData.responsesData[taskId] = [NSMutableData dataWithData:data];
        }
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    PDSSessionData *sessionData = [self sessionDataWithSession:session];
    NSNumber *taskId = @(task.taskIdentifier);
    if ([task isKindOfClass:[NSURLSessionUploadTask class]]) {//上传任务回调
        NSMutableData *responseData = sessionData.responsesData[taskId];
        PDSUploadResponseBlockStorage uploadHandlerBlock = sessionData.uploadHandlers[taskId];
        if (uploadHandlerBlock) {//这是一个上传任务的完成回调
            NSOperationQueue *queueToUse = sessionData.responseHandlerQueues[taskId] ?: [NSOperationQueue mainQueue];
            [queueToUse addOperationWithBlock:^{
                uploadHandlerBlock(responseData, task.response, task.error);
            }];
            [sessionData.downloadHandlers removeObjectForKey:taskId];
            [sessionData.responsesData removeObjectForKey:taskId];
            [sessionData.responseHandlerQueues removeObjectForKey:taskId];
        } else {//普通的接口请求
            PDSAPIResponseBlockStorage responseHandler = sessionData.apiResponseHandlers[taskId];
            if (responseHandler) {//有回调，直接调用回调
                NSOperationQueue *queueToUse = sessionData.responseHandlerQueues[taskId] ?: [NSOperationQueue mainQueue];
                [queueToUse addOperationWithBlock:^{
                    responseHandler(responseData, task.response, error);
                }];
                [sessionData.apiResponseHandlers removeObjectForKey:taskId];
                [sessionData.responsesData removeObjectForKey:taskId];
                [sessionData.responseHandlerQueues removeObjectForKey:taskId];
            } else {//没有回调，先把返回数据暂存起来
                sessionData.completionData[taskId] = [[PDSCompletionData alloc] initWithCompletionData:responseData
                                                                                     responseMetadata:task.response
                                                                                        responseError:error
                                                                                            urlOutput:nil];
            }
        }
    }
    else if ([task isKindOfClass:[NSURLSessionDataTask class]]) {
        NSMutableData *responseData = sessionData.responsesData[taskId];
        PDSDownloadResponseBlockStorage downloadResponseBlock = sessionData.downloadHandlers[taskId];
        if (downloadResponseBlock) {//这是一个下载任务的完成回调
            NSOperationQueue *queueToUse = sessionData.responseHandlerQueues[taskId] ?: [NSOperationQueue mainQueue];
            [queueToUse addOperationWithBlock:^{
                downloadResponseBlock(task.currentRequest.URL, (NSHTTPURLResponse *)task.response, task.error);
            }];
            [sessionData.downloadHandlers removeObjectForKey:taskId];
            [sessionData.responsesData removeObjectForKey:taskId];
            [sessionData.responseHandlerQueues removeObjectForKey:taskId];
        } else {//普通的接口请求
            PDSAPIResponseBlockStorage responseHandler = sessionData.apiResponseHandlers[taskId];
            if (responseHandler) {//有回调，直接调用回调
                NSOperationQueue *queueToUse = sessionData.responseHandlerQueues[taskId] ?: [NSOperationQueue mainQueue];
                [queueToUse addOperationWithBlock:^{
                    responseHandler(responseData, task.response, error);
                }];
                [sessionData.apiResponseHandlers removeObjectForKey:taskId];
                [sessionData.responsesData removeObjectForKey:taskId];
                [sessionData.responseHandlerQueues removeObjectForKey:taskId];
            } else {//没有回调，先把返回数据暂存起来
                sessionData.completionData[taskId] = [[PDSCompletionData alloc] initWithCompletionData:responseData
                                                                                     responseMetadata:task.response
                                                                                        responseError:error
                                                                                            urlOutput:nil];
            }
        }
    }

}

- (void)      URLSession:(NSURLSession *)session
                    task:(NSURLSessionTask *)task
         didSendBodyData:(int64_t)bytesSent
          totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    PDSSessionData *sessionData = [self sessionDataWithSession:session];
    NSNumber *taskId = @(task.taskIdentifier);

    if ([task isKindOfClass:[NSURLSessionDataTask class]]) {
        PDSProgressBlock progressHandler = sessionData.progressHandlers[taskId];
        if (progressHandler) {
            NSOperationQueue *queueToUse = sessionData.progressHandlerQueues[taskId] ?: [NSOperationQueue mainQueue];
            [queueToUse addOperationWithBlock:^{
                progressHandler(bytesSent, totalBytesSent, totalBytesExpectedToSend);
            }];
        } else {
            sessionData.progressData[taskId] = [[PDSProgressData alloc] initWithCommitted:(uint64_t) bytesSent
                                                                          totalCommitted:(uint64_t) totalBytesSent
                                                                        expectedToCommit:(uint64_t) totalBytesExpectedToSend];
        }
    }
}

#pragma mark Util

- (NSString *)sessionIdWithSession:(NSURLSession *)session {
    return session.configuration.identifier ?: kSDSDKForegroundSessionId;
}

- (PDSSessionData *)sessionDataWithSession:(NSURLSession *)session {
    NSString *sessionId = [self sessionIdWithSession:session];
    if (!_sessionData[sessionId]) {
        _sessionData[sessionId] = [[PDSSessionData alloc] initWithSessionId:sessionId];
    }
    return _sessionData[sessionId];
}

#pragma mark Add Handles

- (void)addDownloadDataReceiveHandlerForTaskWithIdentifier:(NSUInteger)identifier session:(NSURLSession *)session dataReceivedHandler:(PDSDownloadDataReceivedBlock)dataReceivedBlock dataReceiveHandlerQueue:(NSOperationQueue *)dataReceiveHandlerQueue {
    [self.delegateQueue addOperationWithBlock:^{
        NSNumber *taskIdentifier = @(identifier);
        PDSSessionData *sessionData = [self sessionDataWithSession:session];
        if (dataReceivedBlock) {
            sessionData.dataReceiveHandlers[taskIdentifier] = dataReceivedBlock;
        }
        if (dataReceiveHandlerQueue) {
            sessionData.dataReceiveHandlersQueues[taskIdentifier] = dataReceiveHandlerQueue;
        }
    }];
}

- (void)addDownloadResponseHandlerForTaskWithIdentifier:(NSUInteger)identifier session:(NSURLSession *)session downloadResponseHandler:(PDSDownloadResponseBlockStorage)downloadHandler responseHandlerQueue:(NSOperationQueue *)responseHandlerQueue {
    [self.delegateQueue addOperationWithBlock:^{
        NSNumber *taskIdentifier = @(identifier);
        PDSSessionData *sessionData = [self sessionDataWithSession:session];
        PDSCompletionData *completionData = sessionData.completionData[taskIdentifier];
        if (completionData) {
            NSOperationQueue *queue = responseHandlerQueue ?: [NSOperationQueue mainQueue];
            [queue addOperationWithBlock:^{
                downloadHandler(completionData.urlOutput, (NSHTTPURLResponse *)completionData.responseMetadata, completionData.responseError);
            }];
            [sessionData.completionData removeObjectForKey:taskIdentifier];
            [sessionData.downloadHandlers removeObjectForKey:taskIdentifier];
            [sessionData.responseHandlerQueues removeObjectForKey:taskIdentifier];
        } else {
            sessionData.downloadHandlers[taskIdentifier] = downloadHandler;
            if (responseHandlerQueue) {
                sessionData.responseHandlerQueues[taskIdentifier] = responseHandlerQueue;
            }
        }
    }];
}

- (void)addUploadResponseHandlerForTaskWithIdentifier:(NSUInteger)identifier session:(NSURLSession *)session uploadResponseHandler:(PDSUploadResponseBlockStorage)uploadResponseHandler responseHandlerQueue:(NSOperationQueue *)responseHandlerQueue {
    [self.delegateQueue addOperationWithBlock:^{
        NSNumber *taskIdentifier = @(identifier);
        PDSSessionData *sessionData = [self sessionDataWithSession:session];
        PDSCompletionData *completionData = sessionData.completionData[taskIdentifier];
        if (completionData) {
            NSOperationQueue *queue = responseHandlerQueue ?: [NSOperationQueue mainQueue];
            [queue addOperationWithBlock:^{
                uploadResponseHandler(completionData.responseBody, completionData.responseMetadata, completionData.responseError);
            }];
            [sessionData.completionData removeObjectForKey:taskIdentifier];
            [sessionData.uploadHandlers removeObjectForKey:taskIdentifier];
            [sessionData.responseHandlerQueues removeObjectForKey:taskIdentifier];
        } else {
            sessionData.uploadHandlers[taskIdentifier] = uploadResponseHandler;
            if (responseHandlerQueue) {
                sessionData.responseHandlerQueues[taskIdentifier] = responseHandlerQueue;
            }
        }
    }];
}


- (void)addAPIResponseHandlerForTaskWithIdentifier:(NSUInteger)identifier session:(NSURLSession *)session ResponseHandler:(PDSAPIResponseBlockStorage)responseHandler responseHandlerQueue:(NSOperationQueue *)responseHandlerQueue {
    [self.delegateQueue addOperationWithBlock:^{
        NSNumber *taskId = @(identifier);
        PDSSessionData *sessionData = [self sessionDataWithSession:session];
        PDSCompletionData *completionData = sessionData.completionData[taskId];
        if (completionData) {//接口请求结果已经返回
            NSOperationQueue *queueToUse = responseHandlerQueue ?: [NSOperationQueue mainQueue];
            [queueToUse addOperationWithBlock:^{
                responseHandler(completionData.responseBody, completionData.responseMetadata, completionData.responseError);
            }];

            [sessionData.completionData removeObjectForKey:taskId];
            [sessionData.apiResponseHandlers removeObjectForKey:taskId];
            [sessionData.progressHandlers removeObjectForKey:taskId];
            [sessionData.progressData removeObjectForKey:taskId];
            [sessionData.responseHandlerQueues removeObjectForKey:taskId];
            [sessionData.progressHandlerQueues removeObjectForKey:taskId];
        } else {//先注册接口请求结果回调
            sessionData.apiResponseHandlers[taskId] = responseHandler;
            if (responseHandlerQueue) {
                sessionData.responseHandlerQueues[taskId] = responseHandlerQueue;
            }
        }
    }];
}

- (void)addProgressResponseHandlerForTaskWithIdentifier:(NSUInteger)identifier session:(NSURLSession *)session progressHandler:(PDSProgressBlock)progressHandler progressHandlerQueue:(NSOperationQueue *)progressHandlerQueue {
    [self.delegateQueue addOperationWithBlock:^{
        NSNumber *taskId = @(identifier);
        PDSSessionData *sessionData = [self sessionDataWithSession:session];
        PDSProgressData *progressData = sessionData.progressData[taskId];
        if (progressData) {//历史数据返回
            NSOperationQueue *queueToUse = progressHandlerQueue ?: [NSOperationQueue mainQueue];
            [queueToUse addOperationWithBlock:^{
                progressHandler(progressData.committed, progressData.totalCommitted, progressData.expectedToCommit);
            }];

            [sessionData.completionData removeObjectForKey:taskId];
            [sessionData.apiResponseHandlers removeObjectForKey:taskId];
            [sessionData.progressHandlers removeObjectForKey:taskId];
            [sessionData.progressData removeObjectForKey:taskId];
            [sessionData.responseHandlerQueues removeObjectForKey:taskId];
            [sessionData.progressHandlerQueues removeObjectForKey:taskId];
        } else {//先注册接口请求结果回调
            sessionData.progressHandlers[taskId] = progressHandler;
            if (progressHandlerQueue) {
                sessionData.progressHandlerQueues[taskId] = progressHandlerQueue;
            }
        }
    }];
}


@end
