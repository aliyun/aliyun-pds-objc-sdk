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

#import "PDSAPICopyFileRequest.h"
#import "PDSAPICopyFileResponse.h"

@implementation PDSAPICopyFileRequest

- (instancetype)initWithFileID:(NSString *)fileID driveID:(NSString *)driveID toParentFileID:(NSString *)toParentFileID toDriveID:(NSString *)toDriveID autoRename:(BOOL)autoRename newName:(NSString *)neoName {
    self = [super init];
    if (self) {
        self.fileID = fileID;
        self.driveID = driveID;
        self.toParentFileID = toParentFileID;
        self.toDriveID = toDriveID;
        self.autoRename = autoRename;
        self.neoName = neoName;
    }

    return self;
}


- (NSString *)endPoint {
    return @"/v2/file/copy";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPICopyFileResponse class];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"driveID": @"drive_id",
            @"fileID": @"file_id",
            @"toParentFileID" : @"to_parent_file_id",
            @"toDriveID" : @"to_drive_id",
            @"neoName" : @"new_name",
            @"autoRename" : @"auto_rename"
    };
}
@end
