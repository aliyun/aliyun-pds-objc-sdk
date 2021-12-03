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

typedef NS_ENUM(NSInteger, PDSRequestErrorType) {
    PDSRequestErrorTypeClient,
    PDSRequestErrorTypeInvalidParameter,
    PDSRequestErrorTypeAuthInvalid,
    PDSRequestErrorTypeNoPermission,
    PDSRequestErrorTypeNotFound,
    PDSRequestErrorTypeInternalError,
    PDSRequestErrorTypeServiceUnavailable,
    PDSRequestErrorTypeUnknown
};

@interface PDSRequestError : NSObject
@property(nonatomic, assign) PDSRequestErrorType type;
///HTTP状态码
@property(nonatomic, assign) NSInteger statusCode;
///服务端返回的错误Code，具体错误code内容见https://help.aliyun.com/document_detail/175927.html
@property(nonatomic, copy) NSString *code;
///服务端返回的具体出错信息
@property(nonatomic, copy) NSString *message;
///客户端的错误
@property(nonatomic, strong) NSError *clientError;

+ (id)invalidResponseError;

- (id)initWithErrorType:(PDSRequestErrorType)errorType statusCode:(NSInteger)statusCode errorCode:(NSString *)errorCode errorMessage:(NSString *)errorMessage clientError:(NSError *)clientError;

- (id)initAsClientError:(NSError *)error;

@end
