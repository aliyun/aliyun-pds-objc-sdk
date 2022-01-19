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
@property(nonatomic, readonly) NSString *downloadUrl;
@property(nonatomic, readonly) NSString *downloadDestination;
@property(nonatomic, readonly) NSString *downloadFileID;
@property(nonatomic, readonly) NSString *downloadFileName;
@property(nonatomic, readonly) NSString *downloadHash;
@property(nonatomic, readonly) uint64_t downloadSize;

- (void)cleanDownloaded;
@end