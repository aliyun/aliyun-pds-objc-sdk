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

@class PDSClientConfig;
@class PDSDownloadTask;
@class PDSDownloadUrlRequest;
@class PDSRequestError;
@class PDSAPIRequestTask;
@class PDSAPIRequest;
@class PDSUploadTask;
@class PDSUploadFileRequest;
@class PDSUploadPhotoRequest;
@class PDSSessionDelegate;
@class PDSTaskStorageClient;

NS_ASSUME_NONNULL_BEGIN

@interface PDSTransportClient : NSObject
@property(nonatomic, readonly) PDSClientConfig *clientConfig;
@property(nonatomic, readonly) PDSSessionDelegate *delegate;
@property(nonatomic, readonly) NSURLSession *session;
@property(nonatomic, copy) NSString *accessToken;
@property(nonatomic, copy) NSString *userAgent;

- (instancetype)initWithAccessToken:(NSString *)accessToken clientConfig:(PDSClientConfig *)clientConfig;

- (PDSDownloadTask *)requestDownload:(PDSDownloadUrlRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient;

- (PDSUploadTask *)requestUpload:(PDSUploadFileRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient;

- (PDSUploadTask *)requestUploadPhoto:(PDSUploadPhotoRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient;

- (PDSAPIRequestTask *)requestSDAPIRequest:(PDSAPIRequest *)request;

@end

NS_ASSUME_NONNULL_END
