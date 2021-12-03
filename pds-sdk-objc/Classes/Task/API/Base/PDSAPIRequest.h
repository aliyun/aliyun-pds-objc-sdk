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
#import <PDS_SDK/PDSAPIRequestSerialize.h>
#import <PDS_SDK/PDSRequest.h>
#import <PDS_SDK/PDSSerializable.h>

NS_ASSUME_NONNULL_BEGIN

@class PDSAPIResponse;

@interface PDSAPIRequest : PDSRequest <PDSAPIRequestSerialize>

/**
 * 接口地址
 * @return 接口地址
 */
- (NSString *)endPoint;

/**
 * 返回响应对象类，用于处理接口返回数据
 * @return 实现序列化方法的对象类
 */
- (Class <PDSSerializable>)responseClass;

/**
 * 返回接口的HTTP方法类型,默认类型为POST
 * @return HTTP方法类型
 */
- (NSString *)requestMethod;

@end

NS_ASSUME_NONNULL_END
