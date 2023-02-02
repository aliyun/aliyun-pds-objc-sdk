// /*
// * Copyright 2009-2022 Alibaba Cloud All rights reserved.
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
#import "PDSDownloadTaskInfoStorageContext.h"
#import "PDSTaskFileSectionInfo.h"


@implementation PDSDownloadTaskInfoStorageContext {

}
- (NSDictionary *)storageInfo {
    NSMutableDictionary *storageInfo = [[NSMutableDictionary alloc] init];
    storageInfo[@"path"] = self.path;
    storageInfo[@"driveID"] = self.driveId ?: @"";
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
        self.driveId = storageInfo[@"driveID"];
        self.fileId = storageInfo[@"fileID"];
        self.taskIdentifier = storageInfo[@"identifier"];
        self.sectionSize = [storageInfo[@"sectionSize"] integerValue];
        self.status = [storageInfo[@"status"] integerValue];
    }
    return self;
}

- (id)initWithTaskIdentifier:(NSString *)taskIdentifier fileID:(NSString *)fileID driveID:(NSString *)driveID path:(NSString *)path sectionSize:(NSInteger)sectionSize status:(NSInteger)status {
    self = [super init];
    if (self) {
        self.taskIdentifier = taskIdentifier;
        self.path = path;
        self.driveId = driveID;
        self.fileId = fileID;
        self.sectionSize = sectionSize;
        self.status = status;
    }
    return self;
}
@end