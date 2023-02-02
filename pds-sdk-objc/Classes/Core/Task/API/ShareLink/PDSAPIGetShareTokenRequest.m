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
#import "PDSAPIGetShareTokenRequest.h"
#import "PDSAPIGetShareTokenResponse.h"


@implementation PDSAPIGetShareTokenRequest {

}
- (instancetype)initWithShareId:(NSString *)shareId sharePassword:(NSString *)sharePassword
             checkSharePassword:(BOOL)checkSharePassword {
    self = [super init];
    if (self) {
        self.shareId = shareId;
        self.sharePassword = sharePassword;
        self.checkSharePassword = checkSharePassword;
    }

    return self;
}


- (NSString *)endPoint {
    return @"/v2/share_link/get_share_token";
}


- (Class <PDSSerializable>)responseClass {
    return [PDSAPIGetShareTokenResponse class];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"shareId" : @"share_id",
            @"sharePassword" : @"share_pwd",
            @"checkSharePassword" : @"check_share_pwd"
    };
}

@end