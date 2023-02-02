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
#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIGetDownloadUrlRequest : PDSAPIRequest
/**
 * 分享ID
 */
@property(nonatomic, copy) NSString *shareID;
/**
 * 存储空间ID
 */
@property(nonatomic, copy) NSString *driveID;
/**
 * 文件唯一标识,必选
 */
@property(nonatomic, copy) NSString *fileID;
/**
 * 文件名
 */
@property(nonatomic, copy) NSString *fileName;
/**
 * 分享令牌
 */
@property(nonatomic, copy) NSString *shareToken;
/**
 * 版本ID，用于历史版本文件下载，可选。默认不传值的话，会返回最新版本的文件
 */
@property(nonatomic, copy) NSString *revisionId;


- (instancetype)initWithShareID:(NSString *__nullable)shareID driveID:(NSString *)driveID fileID:(NSString *)fileID
                       fileName:(NSString *__nullable)fileName shareToken:(NSString *__nullable)shareToken
                     revisionId:(NSString *__nullable)revisionId;

@end

NS_ASSUME_NONNULL_END
