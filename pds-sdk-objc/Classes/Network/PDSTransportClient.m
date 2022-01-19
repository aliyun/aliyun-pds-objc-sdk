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

#import "PDSTransportClient.h"
#import "PDSClientConfig.h"
#import "PDSDownloadUrlRequest.h"
#import "PDSDownloadUrlTaskImpl.h"
#import "PDSSessionDelegate.h"
#import "PDSAPIRequestTaskImpl.h"
#import "PDSAPIRequest.h"
#import "PDSTransportClient+Internal.h"
#import "PDSUploadFileTaskImpl.h"
#import "PDSUploadPhotoTaskImpl.h"
#import "PDSTaskStorageClient.h"
#import <extobjc/EXTScope.h>

@interface PDSTransportClient ()
@property(nonatomic, strong) PDSClientConfig *clientConfig;
@property(nonatomic, strong) PDSSessionDelegate *delegate;
@property(nonatomic, strong) NSURLSession *session;
@end

@implementation PDSTransportClient

- (instancetype)initWithAccessToken:(NSString *)accessToken clientConfig:(PDSClientConfig *)clientConfig {
    self = [self init];
    self.accessToken = accessToken;
    self.clientConfig = clientConfig;
    [self setup];
    return self;
}

- (void)setup {
    self.delegate = [[PDSSessionDelegate alloc] init];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 60.0;
    NSOperationQueue *sessionDelegateQueue =
            [self urlSessionDelegateQueueWithName:[NSString stringWithFormat:@"%@ NSURLSession sessionDelegate queue",
                                                                             NSStringFromClass(self.class)]];
    self.session =
            [NSURLSession sessionWithConfiguration:sessionConfig delegate:self.delegate delegateQueue:sessionDelegateQueue];
}

#pragma mark Create Request

- (PDSDownloadTask *)requestDownload:(PDSDownloadUrlRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient {
    PDSDownloadUrlTaskImpl *task = [[PDSDownloadUrlTaskImpl alloc] initWithRequest:request
                                                                        identifier:identifier
                                                                           session:self.session
                                                                   sessionDelegate:self.delegate
                                                                   transportClient:self
                                                                     storageClient:storageClient];
    [task resume];
    return task;
}

- (PDSUploadTask *)requestUpload:(PDSUploadFileRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient {
    PDSUploadTask *task = [[PDSUploadFileTaskImpl alloc] initWithRequest:request
                                                              identifier:identifier
                                                                 session:self.session
                                                         sessionDelegate:self.delegate
                                                         transportClient:self
                                                           storageClient:storageClient];
    [task resume];
    return task;
}

- (PDSUploadTask *)requestUploadPhoto:(PDSUploadPhotoRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient {
    PDSUploadTask *task = [[PDSUploadPhotoTaskImpl alloc] initWithRequest:request
                                                               identifier:identifier
                                                                  session:self.session
                                                          sessionDelegate:self.delegate
                                                          transportClient:self
                                                            storageClient:storageClient];
    [task resume];
    return task;
}


- (PDSAPIRequestTaskImpl *)requestSDAPIRequest:(PDSAPIRequest *)request {
    @weakify(self);
    PDSURLSessionTaskCreationBlock taskCreationBlock = ^{
        @strongify(self);
        NSURL *requestUrl = [self urlWithRequest:request];
        NSData *requestBodyData = [self serializeBodyDataWithRequest:request];
        NSURLRequest *urlRequest = [self requestWithUrl:requestUrl method:request.requestMethod headers:request.headerParams content:requestBodyData];
        return [self.session dataTaskWithRequest:urlRequest];
    };
    PDSAPIRequestTaskImpl *task = [[PDSAPIRequestTaskImpl alloc] initWithRequest:request
                                                        sessionTaskCreateBlock:taskCreationBlock
                                                                       session:self.session
                                                               sessionDelegate:self.delegate];
    [task resume];
    return task;
}

#pragma mark Util


- (NSOperationQueue *)urlSessionDelegateQueueWithName:(NSString *)queueName {
    NSOperationQueue *sessionDelegateQueue = [[NSOperationQueue alloc] init];
    sessionDelegateQueue.maxConcurrentOperationCount = 1;
    sessionDelegateQueue.name = queueName;
    sessionDelegateQueue.qualityOfService = NSQualityOfServiceUtility;
    return sessionDelegateQueue;
}

@end
