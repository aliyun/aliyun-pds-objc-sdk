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
@class PDSAPIImageMetaData;
@class PDSAPIVideoMetaData;

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,PDSAPICreateFileType){
    PDSAPICreateFileTypeFile,//文件
    PDSAPICreateFileTypeFolder//文件夹
};

@interface PDSAPICreateFileRequest : PDSAPIRequest
///分享ID,同磁盘ID两者必填之一
@property(nonatomic, copy) NSString *shareID;
///磁盘ID,同分享ID两者必填之一
@property(nonatomic, copy) NSString *driveID;
///父文件夹ID,根目录的话传空,必填
@property(nonatomic, copy) NSString *parentFileID;
///文件名,必填
@property(nonatomic, copy) NSString *fileName;
///文件ID，选填
@property(nonatomic, copy) NSString *fileID;
///MIME类型,可选
@property(nonatomic, copy) NSString *contentType;
///文件大小，单位byte,必填
@property(nonatomic, assign) uint64_t size;
///文件hash值，现在只支持sha1，可选
@property(nonatomic, copy) NSString *hashValue;
///文件类型,file 文件/folder 文件夹
@property(nonatomic, assign) PDSAPICreateFileType type;
///文件预上传hash值，可选
@property(nonatomic, copy) NSString *preHashValue;
///文件元数据,可选
@property(nonatomic, copy) NSDictionary *userMeta;
///图片元数据，可选
@property(nonatomic, strong) PDSAPIImageMetaData *imageMeta;
///视频元数据，可选
@property(nonatomic, strong) PDSAPIVideoMetaData *videoMeta;
///分片大小,单位为byte
@property(nonatomic, assign) uint64_t sectionSize;
///分片数量
@property(nonatomic, assign) NSUInteger sectionCount;


- (instancetype)initWithShareID:(NSString *_Nullable)shareID driveID:(NSString *_Nullable)driveID parentFileID:(NSString *)parentFileID fileName:(NSString *)fileName fileID:(NSString *_Nullable)fileID fileSize:(uint64_t)fileSize hashValue:(NSString *_Nullable)hashValue preHashValue:(NSString *_Nullable)preHashValue sectionSize:(uint64_t)sectionSize sectionCount:(NSUInteger)sectionCount;

@end

NS_ASSUME_NONNULL_END
