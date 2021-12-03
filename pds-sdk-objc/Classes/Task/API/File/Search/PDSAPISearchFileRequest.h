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

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPISearchFileRequest : PDSAPIRequest
///要搜索的磁盘driveID，必填
@property(nonatomic, copy) NSString *driveID;
//图片缩略图处理函数 "image/resize,m_fill,h_128,w_128,limit_0"
@property(nonatomic, copy) NSString *imageThumbnailProcess;
//图片Url处理函数 "image/resize,m_fill,h_128,w_128,limit_0"
@property(nonatomic, copy) NSString *imageUrlProcess;
//视频缩略图处理函数 "video/snapshot,t_7000,f_jpg,w_800,h_600,m_fast"
@property(nonatomic, copy) NSString *videoThumbnailProcess;
//搜索最大返回结果数量，默认10个，最多100，最小1
@property(nonatomic, assign) NSInteger limit;
//
@property(nonatomic, copy) NSString *marker;
//排序因子,"updated_at"
@property(nonatomic, copy) NSString *orderBy;
//搜索条件 "not name=\"123\""
@property(nonatomic, copy) NSString *query;
//下载url的过期时间,默认值 : 900 最小值 : 10 最大值 : 14400
@property(nonatomic, assign) uint64_t expireTime;

- (instancetype)initWithDriveID:(NSString *)driveID imageThumbnailProcess:(NSString *_Nullable)imageThumbnailProcess imageUrlProcess:(NSString *_Nullable)imageUrlProcess videoThumbnailProcess:(NSString *_Nullable)videoThumbnailProcess limit:(NSInteger)limit marker:(NSString *_Nullable)marker orderBy:(NSString *_Nullable)orderBy query:(NSString *_Nullable)query expireTime:(uint64_t)expireTime;

@end

NS_ASSUME_NONNULL_END
