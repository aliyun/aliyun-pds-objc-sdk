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

@class PDSFileSubSection;

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPICompleteFileRequest : PDSAPIRequest
/**
 * 分享ID
 */
@property(nonatomic, copy) NSString *shareID;
/**
 * 存储空间ID
 */
@property(nonatomic, copy) NSString *driveID;
/**
 * 文件ID
 */
@property(nonatomic, copy) NSString *fileID;
/**
 * 上传ID
 */
@property(nonatomic, copy) NSString *uploadID;
/**
 * 父文件夹ID,根目录的话传空
 */
@property(nonatomic, copy) NSString *parentFileID;
/**
 * 文件名
 */
@property(nonatomic, copy) NSString *fileName;
/**
 * MIME类型
 */
@property(nonatomic, copy) NSString *contentType;
//分享令牌，用于分享上传文件
@property(nonatomic, copy) NSString *shareToken;

- (instancetype)initWithShareID:(NSString *_Nullable)shareID driveID:(NSString *_Nullable)driveID fileID:(NSString *)fileID uploadID:(NSString *)uploadID parentFileID:(NSString *)parentFileID fileName:(NSString *)fileName contentType:(NSString *_Nullable)contentType shareToken:(NSString *_Nullable)shareToken;

@end

NS_ASSUME_NONNULL_END
