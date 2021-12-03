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

#import "PDSAPIGetFileRequest.h"
#import "PDSAPIGetFileResponse.h"
#import <YYModel/NSObject+YYModel.h>


@implementation PDSAPIGetFileRequest {

}
- (instancetype)initWithFileID:(NSString *)fileID driveID:(NSString *)driveID fields:(NSString *)fields imageThumbnailProcess:(NSString *)imageThumbnailProcess imageUrlProcess:(NSString *)imageUrlProcess videoThumbnailProcess:(NSString *)videoThumbnailProcess expireTime:(uint64_t)expireTime {
    self = [super init];
    if (self) {
        self.fileID = fileID;
        self.driveID = driveID;
        self.fields = fields;
        self.imageThumbnailProcess = imageThumbnailProcess;
        self.imageUrlProcess = imageUrlProcess;
        self.videoThumbnailProcess = videoThumbnailProcess;
        self.expireTime = ((expireTime == 0) ? 900 : expireTime);
    }

    return self;
}


- (NSString *)endPoint {
    return @"/v2/file/get";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPIGetFileResponse class];
}

- (NSDictionary *)requestParams {
    return [self yy_modelToJSONObject];
}


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"driveID": @"drive_id",
            @"fileID": @"file_id",
            @"imageThumbnailProcess": @"image_thumbnail_process",
            @"imageUrlProcess": @"image_url_process",
            @"videoThumbnailProcess": @"video_thumbnail_process",
            @"expireTime": @"url_expire_sec"
    };
}

@end
