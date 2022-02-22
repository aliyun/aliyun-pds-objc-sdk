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
#import "PDSTestConfig.h"

@interface PDSTestConfig (DownloadTask)
//普通下载文件
@property(nonatomic, readonly) NSString *normalDownloadUrl;
@property(nonatomic, readonly) NSString *normalDownloadFileID;
@property(nonatomic, readonly) NSString *normalDownloadFileName;
@property(nonatomic, readonly) uint64_t normalDownloadSize;
@property(nonatomic, readonly) NSString *normalDownloadHash;

//live photo
@property(nonatomic, readonly) NSString *livepDownloadUrl;
@property(nonatomic, readonly) NSString *livepDownloadFileID;
@property(nonatomic, readonly) NSString *livepDownloadFileName;
@property(nonatomic, readonly) uint64_t livepDownloadSize;
@property(nonatomic, readonly) NSString *livepDownloadHash;

@property(nonatomic, readonly) NSString *downloadDestination;

- (void)cleanDownloaded;
@end