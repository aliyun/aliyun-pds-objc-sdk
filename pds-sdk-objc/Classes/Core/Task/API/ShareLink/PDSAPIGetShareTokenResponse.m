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
#import "PDSAPIGetShareTokenResponse.h"
#import <YYModel/NSObject+YYModel.h>


@implementation PDSAPIGetShareTokenResponse {

}
+ (nullable NSDictionary<NSString *, id> *)serialize:(id)instance {
    return nil;
}

+ (id)deserialize:(NSDictionary<NSString *, id> *)dict {
    return [self yy_modelWithDictionary:dict];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"shareToken": @"share_token",
            @"expireTime": @"expire_time",
            @"expireIn": @"expires_in"
    };
}
@end