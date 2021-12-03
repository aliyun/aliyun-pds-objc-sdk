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

#import "PDSAPIUpdateFileRequest.h"
#import "PDSAPIUpdateFileResponse.h"
#import <YYModel/NSObject+YYModel.h>


@implementation PDSAPIUpdateFileRequest {

}

- (instancetype)initWithFileID:(NSString *)fileID driveID:(NSString *)driveID name:(NSString *)name desc:(NSString *)desc hidden:(BOOL)hidden encryptMode:(NSString *)encryptMode starred:(BOOL)starred customIndexKey:(NSString *)customIndexKey labels:(NSArray<NSString *> *)labels userMeta:(NSString *)userMeta {
    self = [super init];
    if (self) {
        self.fileID = fileID;
        self.name = name;
        self.desc = desc;
        self.driveID = driveID;
        self.hidden = hidden;
        self.encryptMode = encryptMode;
        self.starred = starred;
        self.customIndexKey = customIndexKey;
        self.labels = labels;
        self.userMeta = userMeta;
    }
    return self;
}

- (NSString *)endPoint {
    return @"/v2/file/update";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPIUpdateFileResponse class];
}

- (NSDictionary *)requestParams {
    return [self yy_modelToJSONObject];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"customIndexKey": @"custom_index_key",
            @"desc": @"description",
            @"driveID": @"drive_id",
            @"encryptMode": @"encrypt_mode",
            @"fileID": @"file_id",
            @"userMeta": @"user_meta",

    };
}
@end