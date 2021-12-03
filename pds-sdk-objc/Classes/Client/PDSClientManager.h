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

#import <Foundation/Foundation.h>

@class PDSClientConfig;
@class PDSUserClient;

NS_ASSUME_NONNULL_BEGIN

@interface PDSClientManager : NSObject

+ (void)setupWithAccessToken:(NSString *)accessToken;

+ (void)setupWithAccessToken:(NSString *)accessToken clientConfig:(PDSClientConfig *)config;

+ (PDSUserClient *)defaultClient;

@end

NS_ASSUME_NONNULL_END
