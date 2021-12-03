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

#import "PDSAPICompleteFileRequest.h"
#import "PDSAPICompleteFileResponse.h"
#import "PDSMacro.h"
#import "PDSFileSubSection.h"


@implementation PDSAPICompleteFileRequest {

}
- (instancetype)initWithShareID:(NSString *)shareID driveID:(NSString *)driveID fileID:(NSString *)fileID uploadID:(NSString *)uploadID parentFileID:(NSString *)parentFileID fileName:(NSString *)fileName contentType:(NSString *)contentType {
    self = [super init];
    if (self) {
        _shareID = [shareID copy];
        _driveID = [driveID copy];
        _fileID = [fileID copy];
        _uploadID = [uploadID copy];
        _parentFileID = [parentFileID copy];
        _fileName = [fileName copy];
        _contentType = [contentType copy];
    }

    return self;
}


- (NSString *)endPoint {
    return @"/v2/file/complete";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPICompleteFileResponse class];
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
    params[@"type"] = @"file";
    params[@"content_type"] = self.contentType;
    params[@"file_id"] = self.fileID;
    params[@"upload_id"] = self.uploadID;
    return [params copy];
}

@end