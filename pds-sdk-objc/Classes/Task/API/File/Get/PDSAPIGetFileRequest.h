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

@interface PDSAPIGetFileRequest : PDSAPIRequest
///要上传的文件的fileID，必填
@property(nonatomic, copy) NSString *fileID;
///要上传到的磁盘driveID，可选
@property(nonatomic, copy) NSString *driveID;

@property(nonatomic, copy) NSString *fields;
//图片缩略图处理函数 "image/resize,m_fill,h_128,w_128,limit_0"
@property(nonatomic, copy) NSString *imageThumbnailProcess;
//图片Url处理函数 "image/resize,m_fill,h_128,w_128,limit_0"
@property(nonatomic, copy) NSString *imageUrlProcess;

@property(nonatomic, copy) NSString *videoThumbnailProcess;
//下载url的过期时间,默认值 : 900 最小值 : 10 最大值 : 14400
@property(nonatomic, assign) uint64_t expireTime;

- (instancetype)initWithFileID:(NSString *)fileID driveID:(NSString *)driveID fields:(NSString *_Nullable)fields imageThumbnailProcess:(NSString *_Nullable)imageThumbnailProcess imageUrlProcess:(NSString *_Nullable)imageUrlProcess videoThumbnailProcess:(NSString *_Nullable)videoThumbnailProcess expireTime:(uint64_t)expireTime;

@end

NS_ASSUME_NONNULL_END
