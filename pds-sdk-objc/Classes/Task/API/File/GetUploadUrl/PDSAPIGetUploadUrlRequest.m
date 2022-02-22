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

#import "PDSAPIGetUploadUrlRequest.h"
#import "PDSSerializable.h"
#import "PDSAPIGetUploadUrlResponse.h"
#import "PDSMacro.h"
#import "PDSAPIUploadFilePartInfoItem.h"
#import <YYModel/NSObject+YYModel.h>


@implementation PDSAPIGetUploadUrlRequest {

}
- (instancetype)initWithFileID:(NSString *)fileID uploadID:(NSString *)uploadID driveID:(NSString *)driveID shareID:(NSString *)shareID partInfoList:(NSArray<PDSAPIUploadFilePartInfoItem *> *)partInfoList contentMd5:(NSString *)contentMd5 {
    self = [super init];
    if (self) {
        _fileID = [fileID copy];
        _uploadID = [uploadID copy];
        _driveID = [driveID copy];
        _shareID = [shareID copy];
        _partInfoList = [partInfoList copy];
        _contentMd5 = [contentMd5 copy];
    }

    return self;
}


- (NSString *)endPoint {
    return @"/v2/file/get_upload_url";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPIGetUploadUrlResponse class];
}

- (NSDictionary *)requestParams {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (!PDSIsEmpty(self.driveID)) {
        params[@"drive_id"] = self.driveID;
    } else if (!PDSIsEmpty(self.shareID)) {
        params[@"share_id"] = self.shareID;
    }
    params[@"file_id"] = self.fileID;
    params[@"upload_id"] = self.uploadID;
    if (!PDSIsEmpty(self.partInfoList)) {
        params[@"part_info_list"] = [self.partInfoList yy_modelToJSONObject];
    }
    if (!PDSIsEmpty(self.contentMd5)) {
        params[@"content_md5"] = self.contentMd5;
    }
    return [params copy];
}
@end
