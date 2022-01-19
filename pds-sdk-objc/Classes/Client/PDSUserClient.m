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

#import "PDSUserClient.h"
#import "PDSTransportClient.h"
#import "PDSTaskStorageClient.h"
#import "PDSFileSession.h"
#import "PDSSDKConstants.h"
#import "PDSClientConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDSUserClient ()
@property(nonatomic, copy) NSString *accessToken;
@property(nonatomic, strong, readwrite) PDSTransportClient *transportClient;
@property(nonatomic, strong, readwrite) PDSTaskStorageClient *storageClient;
@property(nonatomic, strong, readwrite) PDSFileSession *file;
@end

@implementation PDSUserClient
- (instancetype)initWithAccessToken:(NSString *)accessToken clientConfig:(PDSClientConfig *)clientConfig {
    PDSTransportClient *transportClient = [[PDSTransportClient alloc] initWithAccessToken:accessToken clientConfig:clientConfig];
    PDSTaskStorageClient *storageClient = [[PDSTaskStorageClient alloc] initWithDBName:clientConfig.dbName];
    return [self initWithTransportClient:transportClient storageClient:storageClient];
}

- (id)initWithTransportClient:(PDSTransportClient *)transportClient storageClient:(PDSTaskStorageClient *)storageClient {
    self = [super init];
    if (self) {
        self.transportClient = transportClient;
        self.storageClient = storageClient;
        self.file = [[PDSFileSession alloc] initWithTransportClient:transportClient storageClient:storageClient];
    }
    return self;
}

- (void)setAccessToken:(NSString *)accessToken {
    self.transportClient.accessToken = accessToken;
}

- (void)setUserAgent:(NSString *)userAgent {
    self.transportClient.clientConfig.userAgent = userAgent;
}

- (void)setHost:(NSString *)host {
    self.transportClient.clientConfig.host = host;
}

- (void)setEnableFastUpload:(BOOL)enableFastUpload {
    self.transportClient.clientConfig.enableFastUpload = enableFastUpload;
}

- (NSString *)sdkVersion {
    return kSDSDKVersion;
}

@end

NS_ASSUME_NONNULL_END
