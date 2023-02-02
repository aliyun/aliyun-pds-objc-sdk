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

#import "PDSAPIMoveFileRequest.h"
#import "PDSAPIMoveFileResponse.h"

@implementation PDSAPIMoveFileRequest
- (instancetype)initWithDriveID:(NSString *)driveID fileID:(NSString *)fileID toParentFileID:(NSString *)toParentFileID newName:(NSString *)neoName overwrite:(BOOL)overwrite {
    self = [super init];
    if (self) {
        self.driveID = driveID;
        self.fileID = fileID;
        self.toParentFileID = toParentFileID;
        self.neoName = neoName;
        self.overwrite = overwrite;
    }

    return self;
}


- (NSString *)endPoint {
    return @"/v2/file/move";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPIMoveFileResponse class];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"driveID": @"drive_id",
            @"fileID": @"file_id",
            @"toParentFileID" : @"to_parent_file_id",
            @"neoName" : @"new_name"
    };
}

@end
