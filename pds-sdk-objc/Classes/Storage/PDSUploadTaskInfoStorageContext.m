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

#import "PDSUploadTaskInfoStorageContext.h"
#import <PDS_SDK/PDSTaskFileSectionInfo.h>

@implementation PDSUploadTaskInfoStorageContext

- (NSDictionary *)storageInfo {
    NSMutableDictionary *storageInfo = [[NSMutableDictionary alloc] init];
    storageInfo[@"path"] = self.path;
    storageInfo[@"uploadId"] = self.uploadId ?: @"";
    storageInfo[@"fileID"] = self.fileId ?: @"";
    storageInfo[@"identifier"] = self.taskIdentifier;
    storageInfo[@"sectionSize"] = @(self.sectionSize);
    storageInfo[@"status"] = @(self.status);
    return storageInfo;
}


- (id)initWithDictionary:(NSDictionary *)storageInfo {
    self = [super init];
    if (self) {
        self.path = storageInfo[@"path"];
        self.uploadId = storageInfo[@"uploadId"];
        self.fileId = storageInfo[@"fileID"];
        self.taskIdentifier = storageInfo[@"identifier"];
        self.sectionSize = [storageInfo[@"sectionSize"] integerValue];
        self.status = [storageInfo[@"status"] integerValue];
    }
    return self;
}

- (id)initWithTaskIdentifier:(NSString *)taskIdentifier uploadID:(NSString *)uploadID fileID:(NSString *)fileID path:(NSString *)path sectionSize:(uint64_t)sectionSize status:(NSInteger)status {
    self = [super init];
    if (self) {
        self.path = path;
        self.uploadId = uploadID;
        self.fileId = fileID;
        self.taskIdentifier = taskIdentifier;
        self.sectionSize = sectionSize;
        self.status = status;
    }
    return self;
}

@end
