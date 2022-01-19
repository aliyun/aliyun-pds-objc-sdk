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

#import "PDSAPICompleteFileResponse.h"
#import "PDSAPIImageMetaData.h"
#import <YYModel/NSObject+YYModel.h>


@implementation PDSAPICompleteFileResponse {

}

+ (id)deserialize:(NSDictionary<NSString *, id> *)dict {
    return [self yy_modelWithDictionary:dict];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"hashValue": @"content_hash",
            @"hashType": @"content_hash_name",
            @"contentType": @"content_type",
            @"crc64Value": @"crc64_hash",
            @"createdAt": @"created_at",
            @"trashedAt": @"trashed_at",
            @"updatedAt": @"updated_at",
            @"desc": @"description",
            @"domainId": @"domain_id",
            @"downloadUrl": @"download_url",
            @"driveID": @"drive_id",
            @"encryptMode": @"encrypt_mode",
            @"fileExtension": @"file_extension",
            @"fileID": @"file_id",
            @"imageMetaData": @"image_media_metadata",
            @"parentFileID": @"parent_file_id",
            @"uploadID": @"upload_id",
            @"userMeta": @"user_meta",
            @"videoMetaData": @"video_media_metadata"
            };
}


- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dictionary {
    if ([@"uploading" isEqualToString:dictionary[@"status"]]) {
        self.status = PDSAPIFileStatusUploading;
    } else {
        self.status = PDSAPIFileStatusAvailable;
    }
    return YES;
}


@end