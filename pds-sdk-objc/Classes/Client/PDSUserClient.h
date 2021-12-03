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

NS_ASSUME_NONNULL_BEGIN
@class PDSFileSession;
@class PDSClientConfig;
@class PDSAPIClient;

@interface PDSUserClient : NSObject
@property(nonatomic, strong, readonly) PDSFileSession *file;
@property(nonatomic, strong, readonly) PDSAPIClient *api;

- (instancetype)initWithAccessToken:(NSString *)accessToken clientConfig:(PDSClientConfig *)clientConfig;

/// 更新accessToken，当外部业务方发现accessToken要过期前调用这个接口把新的accessToken传入
/// @param accessToken 接口鉴权的token
- (void)setAccessToken:(NSString *)accessToken;

/// 设置userAgent，用于上报给后台当前客户端的类型
/// @param userAgent 当前客户端的UA
- (void)setUserAgent:(NSString *)userAgent;

/// 设置接口的Host
/// @param host 接口的host
- (void)setHost:(NSString *)host;


/// 是否启用快速上传
/// 当启用快速上传的时候，会先计算文件的hash上报服务端，检查是否已经有同个文件已经上传上去
/// 如果已经上传上去了，那么不再执行上传操作，直接完成
/// @param enableFastUpload 是否启用快速上传
- (void)setEnableFastUpload:(BOOL)enableFastUpload;

- (NSString *)sdkVersion;
@end

NS_ASSUME_NONNULL_END
