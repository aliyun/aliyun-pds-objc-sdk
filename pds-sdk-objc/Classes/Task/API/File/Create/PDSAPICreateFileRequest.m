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

#import "PDSAPICreateFileRequest.h"
#import "PDSMacro.h"
#import "PDSAPICreateFileResponse.h"
#import "PDSFileSubSection.h"
#import "PDSAPIVideoMetaData.h"
#import "PDSAPIImageMetaData.h"
#import "PDSAPIUploadFilePartInfoItem.h"
#import <YYModel/YYModel.h>


@interface PDSAPICreateFileRequest ()
@end

@implementation PDSAPICreateFileRequest {

}
- (instancetype)initWithShareID:(NSString *)shareID driveID:(NSString *)driveID parentFileID:(NSString *)parentFileID fileName:(NSString *)fileName fileSize:(uint64_t)fileSize hashValue:(NSString *_Nullable)hashValue preHashValue:(NSString *_Nullable)preHashValue sectionSize:(uint64_t)sectionSize sectionCount:(NSUInteger)sectionCount {
    self = [super init];
    if (self) {
        _shareID = [shareID copy];
        _driveID = [driveID copy];
        _parentFileID = [parentFileID copy];
        _fileName = [fileName copy];
        _size = fileSize;
        _hashValue = [hashValue copy];
        _preHashValue = [preHashValue copy];
        _sectionCount = sectionCount;
        _sectionSize = sectionSize;
    }

    return self;
}


- (NSString *)endPoint {
    return @"/v2/file/create";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPICreateFileResponse class];
}


- (NSDictionary *)requestParams {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (!PDSIsEmpty(self.shareID)) {
        params[@"share_id"] = self.shareID;
    } else {
        params[@"drive_id"] = self.driveID;
    }
    params[@"name"] = self.fileName;
    params[@"parent_file_id"] = self.parentFileID ?: @"root";
    if(self.type == PDSAPICreateFileTypeFile) {
        params[@"type"] = @"file";
    }
    else {
        params[@"type"] = @"folder";
    }
    params[@"content_type"] = self.contentType;
    params[@"size"] = @(self.size);
    if (!PDSIsEmpty(self.preHashValue)) {
        params[@"pre_hash"] = self.preHashValue;
    } else if (!PDSIsEmpty(self.hashValue)) {
        params[@"content_hash"] = self.hashValue;
        params[@"content_hash_name"] = @"sha1";
    }
    params[@"image_media_metadata"] = [self.imageMeta yy_modelToJSONObject];
    params[@"video_media_metadata"] = [self.videoMeta yy_modelToJSONObject];
    params[@"user_meta"] = self.userMeta;
    params[@"check_name_mode"] = @"auto_rename";
    NSMutableArray *partInfoList = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.sectionCount; ++i) {
        PDSAPIUploadFilePartInfoItem *uploadFilePartInfo = [[PDSAPIUploadFilePartInfoItem alloc] init];
        uploadFilePartInfo.partNumber = i + 1;
        uploadFilePartInfo.partSize = self.sectionSize;
        [partInfoList addObject:uploadFilePartInfo];
    }
    params[@"part_info_list"] = [partInfoList yy_modelToJSONObject];
    return [params copy];
}

@end
