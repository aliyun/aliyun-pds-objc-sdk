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
#import <PDS_SDK/PDSTypes.h>

@class PDSAPIImageMetaData;

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPICompleteFileResponse : PDSAPIResponse
@property(nonatomic, copy) NSString *category;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *hashValue;
@property(nonatomic, copy) NSString *hashType;
@property(nonatomic, copy) NSString *uploadID;
@property(nonatomic, copy) NSString *contentType;
@property(nonatomic, copy) NSString *crc64Value;
@property(nonatomic, strong) NSDate *createAt;
@property(nonatomic, strong) NSDate *updatedAt;
@property(nonatomic, strong) NSDate *trashedAt;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, copy) NSString *domainId;
@property(nonatomic, copy) NSString *downloadUrl;
@property(nonatomic, copy) NSString *encryptMode;
@property(nonatomic, copy) NSString *fileExtension;
@property(nonatomic, copy) NSString *fileID;
@property(nonatomic, copy) NSString *hidden;
@property(nonatomic, strong) PDSAPIImageMetaData *imageMetaData;
@property(nonatomic, copy) NSArray<NSString *> *labels;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *parentFileID;
@property(nonatomic, assign) uint64_t size;
@property(nonatomic, assign) BOOL starred;
@property(nonatomic, assign) PDSAPIFileStatus status;
@property(nonatomic, copy) NSString *thumbnail;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *userMeta;
@property(nonatomic, strong) NSString *videoMetaData;
@end

NS_ASSUME_NONNULL_END
