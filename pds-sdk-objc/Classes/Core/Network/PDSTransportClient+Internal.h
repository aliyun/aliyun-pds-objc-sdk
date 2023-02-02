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
#import <PDS_SDK/PDSTransportClient.h>

@class PDSAPIRequest;
@protocol PDSAPIRequestSerialize;

@interface PDSTransportClient (Internal)
- (PDSDownloadTask *)requestDownloadLivePhoto:(PDSDownloadUrlRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient;

- (PDSUploadTask *)requestUploadLivePhoto:(PDSUploadPhotoRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient;

- (NSURL *)urlWithRequest:(PDSAPIRequest *)request;

- (NSData *)serializeBodyDataWithRequest:(PDSAPIRequest <PDSAPIRequestSerialize> *)request;

- (NSURLRequest *)requestWithUrl:(NSURL *)url method:(NSString *)method headers:(NSDictionary *)headers content:(NSData *)content;

+ (PDSRequestError *)requestErrorWithErrorData:(NSData *)errorData clientError:(NSError *)clientError statusCode:(int)statusCode httpHeaders:(NSDictionary *)httpHeaders;

+ (id)resultWithRequest:(PDSAPIRequest *)request data:(NSData *)data serializationError:(NSError **)serializationError;
@end