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

#import "PDSAPIGetDownloadUrlRequest.h"
#import "PDSAPIGetDownloadUrlResponse.h"
#import "PDSMacro.h"


@implementation PDSAPIGetDownloadUrlRequest {

}
- (instancetype)initWithShareID:(NSString *__nullable)shareID driveID:(NSString *)driveID fileID:(NSString *)fileID
                       fileName:(NSString *__nullable)fileName shareToken:(NSString *__nullable)shareToken
                     revisionId:(NSString *__nullable)revisionId {
    self = [super init];
    if (self) {
        _shareID = [shareID copy];
        _driveID = [driveID copy];
        _fileID = [fileID copy];
        _fileName = [fileName copy];
        _shareToken = [shareToken copy];
        _revisionId = revisionId;
    }
    return self;
}


- (NSString *)endPoint {
    return @"/v2/file/get_download_url";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPIGetDownloadUrlResponse class];
}

- (NSDictionary *)requestParams {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (!PDSIsEmpty(self.shareID)) {
        params[@"share_id"] = self.shareID;
    } else {
        params[@"drive_id"] = self.driveID;
    }
    if (!PDSIsEmpty(self.fileName)) {
        params[@"file_name"] = self.fileName;
    }
    if (!PDSIsEmpty(self.fileID)) {
        params[@"file_id"] = self.fileID;
    }
    if (!PDSIsEmpty(self.revisionId)) {
        params[@"revision_id"] = self.revisionId;
    }
    return [params copy];
}

- (NSDictionary *)headerParams {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[super headerParams]];
    if (self.shareToken) {
        params[@"x-share-token"] = self.shareToken;
    }
    return [params copy];
}

@end
