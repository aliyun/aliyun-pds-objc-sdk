//
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

#import <PDS_SDK/PDSRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSUploadPhotoRequest : PDSRequest
//要上传的照片
@property(nonatomic, copy, readonly) NSString *localIdentifier;
// 文件所在目录的唯一标识
@property(nonatomic, copy, readonly) NSString *parentFileID;
// 文件大小
@property(nonatomic, assign, readonly) uint64_t fileSize;
//存储空间ID
@property(nonatomic, copy, readonly) NSString *driveID;
//分享ID
@property(nonatomic, copy, readonly) NSString *shareID;
//分片上传大小，默认为4M
@property(nonatomic, assign, readonly) uint64_t sectionSize;
//文件名
@property(nonatomic, copy) NSString *fileName;

/**
 * 初始化上传文件请求
 * @param localIdentifier 要上传的照片的Asset的localIdentifier
 * @param parentFileID  上传的目录ID，要传到根目录的话设为空
 * @param driveID driverID和shareID其中一个必传
 * @param shareID driverID和shareID其中一个必传
 * @param fileName 文件名，如果为空的话会取照片文件的原始名
 * @return 文件上传请求
 */
- (instancetype)initWithLocalIdentifier:(NSString *)localIdentifier parentFileID:(NSString *)parentFileID driveID:(NSString *_Nullable)driveID shareID:(NSString *_Nullable)shareID fileName:(NSString *_Nullable)fileName;

@end

NS_ASSUME_NONNULL_END
