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
#import <PDS_SDK/PDSAPIResponse.h>
#include "PDSAPIUploadFilePartInfoItem.h"

typedef NS_ENUM(NSInteger, PDSAPICreateFileStatus) {
    PDSAPICreateFileStatusFinished,
    PDSAPICreateFileStatusWaiting
};

@interface PDSAPICreateFileResponse : PDSAPIResponse
/**
 * 文件ID
 */
@property(nonatomic, copy) NSString *fileId;
/**
 * 上传ID
 */
@property(nonatomic, copy) NSString *uploadId;
/**
 * 文件名
 */
@property(nonatomic, copy) NSString *fileName;
/**
 * 历史版本
 */
@property(nonatomic, copy) NSString *revisionId;
/**
 * 完成时间
 */
@property(nonatomic, assign) NSTimeInterval completeTime;
/**
 * 创建文件返回的状态，如果是finish的话说明文件上传已经完成，否则需要继续上传文件分片
 */
@property(nonatomic, assign) PDSAPICreateFileStatus status;

/**
 * 文件要上传的分片信息
 */
@property(nonatomic, copy) NSArray<PDSAPIUploadFilePartInfoItem *> *partInfoList;
@end
