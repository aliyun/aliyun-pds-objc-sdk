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

#import <Foundation/Foundation.h>
#import <PDS_SDK/PDSTypes.h>
#import <PDS_SDK/PDSInternalTypes.h>


@interface PDSSessionDelegate : NSObject <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

- (void)addDownloadDataReceiveHandlerForTaskWithIdentifier:(NSUInteger)identifier
                                                   session:(NSURLSession *)session
                                       dataReceivedHandler:(PDSDownloadDataReceivedBlock)dataReceivedBlock
                                   dataReceiveHandlerQueue:(NSOperationQueue *)dataReceiveHandlerQueue;

- (void)addDownloadResponseHandlerForTaskWithIdentifier:(NSUInteger)identifier
                                                session:(NSURLSession *)session
                                downloadResponseHandler:(PDSDownloadResponseBlockStorage)downloadHandler
                                   responseHandlerQueue:(NSOperationQueue *)responseHandlerQueue;

- (void)addUploadResponseHandlerForTaskWithIdentifier:(NSUInteger)identifier
                                              session:(NSURLSession *)session
                                uploadResponseHandler:(PDSUploadResponseBlockStorage)uploadResponseHandler
                                 responseHandlerQueue:(NSOperationQueue *)responseHandlerQueue;

- (void)addAPIResponseHandlerForTaskWithIdentifier:(NSUInteger)identifier
                                           session:(NSURLSession *)session
                                   ResponseHandler:(PDSAPIResponseBlockStorage)responseHandler
                              responseHandlerQueue:(NSOperationQueue *)responseHandlerQueue;

- (void)addProgressResponseHandlerForTaskWithIdentifier:(NSUInteger)identifier
                                                session:(NSURLSession *)session
                                        progressHandler:(PDSProgressBlock)progressHandler
                                   progressHandlerQueue:(NSOperationQueue *)progressHandlerQueue;
@end