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
#import "PDSRequestError.h"
#import "PDSAPIRequestTaskImpl.h"
#import "PDSDownloadUrlRequest.h"
#import "PDSTransportClient.h"
#import "PDSTransportClient+Internal.h"
#import "PDSAPIRequest.h"
#import "PDSClientConfig.h"
#import "PDSMacro.h"
#import "PDSSerializable.h"
#import "PDSTaskStorageClient.h"


@implementation PDSTransportClient (Internal)
+ (PDSRequestError *)requestErrorWithErrorData:(NSData *)errorData clientError:(NSError *)clientError statusCode:(int)statusCode httpHeaders:(NSDictionary *)httpHeaders {
    if (clientError && errorData == nil) {
        return [[PDSRequestError alloc] initAsClientError:clientError];
    }

    if (statusCode == 200 || statusCode == 201 || statusCode == 202 || statusCode == 204) {
        return nil;
    }

    NSDictionary *deserializedData = [self deserializeHttpData:errorData];
    NSString *errorMessage = nil;
    NSString *errorCode = nil;
    if (deserializedData) {
        errorMessage = deserializedData[@"message"];
        errorCode = deserializedData[@"code"];
    } else {//返回的错误信息无法json化，直接把原始的字符串返回
        errorMessage = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    }
    PDSRequestErrorType errorType = PDSRequestErrorTypeUnknown;
    switch (statusCode) {
        case 400://参数错误
            errorType = PDSRequestErrorTypeInvalidParameter;
            break;
        case 401://token过期
            errorType = PDSRequestErrorTypeAuthInvalid;
            break;
        case 403://没有权限
            errorType = PDSRequestErrorTypeNoPermission;
            break;
        case 404://资源找不到
            errorType = PDSRequestErrorTypeNotFound;
            break;
        case 500://服务器内部错误
            errorType = PDSRequestErrorTypeInternalError;
            break;
        case 503://服务器不可用
            errorType = PDSRequestErrorTypeServiceUnavailable;
            break;
        default:
            errorType = PDSRequestErrorTypeUnknown;
            break;
    }
    return [[PDSRequestError alloc] initWithErrorType:errorType statusCode:statusCode errorCode:errorCode errorMessage:errorMessage clientError:nil];
}


+ (NSDictionary *)deserializeHttpData:(NSData *)data {
    if (!data) {
        return nil;
    }
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingFragmentsAllowed error:&error];
}

- (NSURL *)urlWithRequest:(PDSAPIRequest *)request {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.clientConfig.host, request.endPoint]];
}

- (NSData *)serializeBodyDataWithRequest:(PDSAPIRequest <PDSAPIRequestSerialize> *)request {
    if (PDSIsEmpty(request.requestParams)) {
        return nil;
    }
    return [NSJSONSerialization dataWithJSONObject:request.requestParams options:NSJSONWritingFragmentsAllowed error:nil];
}

- (NSURLRequest *)requestWithUrl:(NSURL *)url method:(NSString *)method headers:(NSDictionary *)headers content:(NSData *)content {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.timeoutInterval = 10;
    [request setValue:self.clientConfig.userAgent forHTTPHeaderField:@"user-agent"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    for (NSString *key in headers) {
        [request addValue:headers[key] forHTTPHeaderField:key];
    }
    method = method ?: @"POST";
    request.HTTPMethod = method;
    if (content) {
        request.HTTPBody = content;
    }
    return request;
}

+ (id)resultWithRequest:(PDSAPIRequest *)request data:(NSData *)data serializationError:(NSError **)serializationError {
    if (!request.responseClass) {
        return nil;
    }
    id jsonData =
            [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:serializationError];
    if (*serializationError) {
        return nil;
    }
    return [(Class<PDSSerializable>) request.responseClass deserialize:jsonData];
}


- (PDSUploadTask *)requestUploadLivePhoto:(PDSUploadPhotoRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient {
    return NULL;
}

- (PDSDownloadTask *)requestDownloadLivePhoto:(PDSDownloadUrlRequest *)request taskIdentifier:(NSString *)identifier storageClient:(PDSTaskStorageClient *)storageClient {
    PDSDownloadLivePhotoTaskImpl *task = [[PDSDownloadLivePhotoTaskImpl alloc] initWithRequest:request identifier:identifier session:self.session sessionDelegate:self.delegate transportClient:self storageClient:storageClient];
    [task resume];
    return task;
}


@end
