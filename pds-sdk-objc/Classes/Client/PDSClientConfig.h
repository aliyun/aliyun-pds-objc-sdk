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

@interface PDSClientConfig : NSObject

/// 接口请求的域名
@property(nonatomic, copy) NSString *host;

/// 请求接口时候附带的UA
@property(nonatomic, copy) NSString *userAgent;

/// 是否启用快速上传，默认为YES
/// 当启用快速上传的时候，会先计算文件的hash上报服务端，检查是否已经有同个文件已经上传上去
/// 如果已经上传上去了，那么不再执行上传操作，直接完成
@property(nonatomic, assign) BOOL enableFastUpload;

/// 数据库初始化的名称，如果不填会用默认值
@property(nonatomic, copy) NSString *dbName;

@end

NS_ASSUME_NONNULL_END
