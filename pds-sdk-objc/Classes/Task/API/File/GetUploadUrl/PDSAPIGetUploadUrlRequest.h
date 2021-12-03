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

@class PDSAPIUploadFilePartInfoItem;

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIGetUploadUrlRequest : PDSAPIRequest
///要上传文件的MD5，可选
@property(nonatomic, copy) NSString *contentMd5;
///要上传到的磁盘driveID，可选
@property(nonatomic, copy) NSString *driveID;
///要上传的文件的fileID，必填
@property(nonatomic, copy) NSString *fileID;
///之前获得的上传分片信息，可选
@property(nonatomic, copy) NSArray<PDSAPIUploadFilePartInfoItem *> *partInfoList;
///之前通过createFile接口获得的uploadID，必填
@property(nonatomic, copy) NSString *uploadID;

- (instancetype)initWithFileID:(NSString *)fileID uploadID:(NSString *)uploadID driveId:(NSString *)driveId partInfoList:(NSArray<PDSAPIUploadFilePartInfoItem *> *)partInfoList contentMd5:(NSString *)contentMd5;

@end

NS_ASSUME_NONNULL_END
