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

#import "PDSClientManager.h"
#import "PDSClientConfig.h"
#import "PDSUserClient.h"

@interface PDSClientManager ()

@end

@implementation PDSClientManager
static PDSClientConfig *_clientConfig;
static PDSUserClient *_userClient;

#pragma mark - Properties
+ (PDSClientConfig *)clientConfig {
    return _clientConfig;
}

+ (void)setClientConfig:(PDSClientConfig *)clientConfig {
    _clientConfig = clientConfig;
}

+ (PDSUserClient *)defaultClient {
    @synchronized (self) {
        return _userClient;
    }
}

+ (void)setUserClient:(PDSUserClient *)userClient {
    @synchronized (self) {
        _userClient = userClient;
    }
}

#pragma mark - Setup
+ (void)setupWithAccessToken:(NSString *)accessToken {
    PDSClientConfig *clientConfig = [[PDSClientConfig alloc] init];
    [[self class] setupWithAccessToken:accessToken clientConfig:clientConfig];
}

+ (void)setupWithAccessToken:(NSString *)accessToken clientConfig:(PDSClientConfig *)config {
    [self setClientConfig:config];
    [self setupClientsWithAccessToken:accessToken];
}

+ (void)setupClientsWithAccessToken:(NSString *)accessToken {
    PDSUserClient *userClient = [[PDSUserClient alloc] initWithAccessToken:accessToken clientConfig:self.clientConfig];
    [self setUserClient:userClient];
}

@end
