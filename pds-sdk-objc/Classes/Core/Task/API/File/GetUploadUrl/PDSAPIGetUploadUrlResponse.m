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

#import "PDSAPIGetUploadUrlResponse.h"
#import "PDSAPIUploadFilePartInfoItem.h"
#import <YYModel/NSObject+YYModel.h>

@implementation PDSAPIGetUploadUrlResponse {

}

+ (nullable NSDictionary<NSString *, id> *)serialize:(id)instance {
    return nil;
}

+ (id)deserialize:(NSDictionary<NSString *, id> *)dict {
    return [self yy_modelWithDictionary:dict];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"createAt": @"create_at",
            @"domainID": @"domain_id",
            @"driveID": @"drive_id",
            @"fileID": @"file_id",
            @"partInfoList": @"part_info_list",
            @"uploadID": @"upload_id"
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
            @"partInfoList" : [PDSAPIUploadFilePartInfoItem class],
    };
}
@end
