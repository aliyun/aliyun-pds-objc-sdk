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

#import "PDSAPISearchFileRequest.h"
#import "PDSAPISearchFileResponse.h"
#import "PDSMacro.h"
#import <YYModel/NSObject+YYModel.h>

@implementation PDSAPISearchFileRequest
- (instancetype)initWithDriveID:(NSString *)driveID imageThumbnailProcess:(NSString *)imageThumbnailProcess imageUrlProcess:(NSString *)imageUrlProcess videoThumbnailProcess:(NSString *)videoThumbnailProcess limit:(NSInteger)limit marker:(NSString *)marker orderBy:(NSString *)orderBy query:(NSString *)query expireTime:(uint64_t)expireTime {
    self = [super init];
    if (self) {
        self.driveID = driveID;
        self.imageThumbnailProcess = imageThumbnailProcess;
        self.imageUrlProcess = imageUrlProcess;
        self.videoThumbnailProcess = videoThumbnailProcess;
        self.limit = ((limit == 0) ? 10 : limit);
        self.marker = marker;
        self.orderBy = PDSIsEmpty(orderBy) ? @"update_at DESC" : orderBy;
        self.query = query;
        self.expireTime = ((expireTime == 0) ? 900 : expireTime);
    }

    return self;
}


- (NSString *)endPoint {
    return @"/v2/file/search";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPISearchFileResponse class];
}

- (NSDictionary *)requestParams {
    return [self yy_modelToJSONObject];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"driveID": @"drive_id",
            @"imageThumbnailProcess": @"image_thumbnail_process",
            @"imageUrlProcess": @"image_url_process",
            @"videoThumbnailProcess": @"video_thumbnail_process",
            @"expireTime": @"url_expire_sec",
            @"orderBy": @"order_by"
    };
}
@end
