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
#import <PDS_SDK/PDSTaskStorage.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSTestStorageContext : NSObject <PDSTaskStorageInfo>
@property(nonatomic, copy) NSString *taskIdentifier;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, copy) NSString *uploadId;
@property(nonatomic, copy) NSString *fileId;
@property(nonatomic, assign) uint64_t sectionSize;
@property(nonatomic, assign) NSInteger status;
@end

NS_ASSUME_NONNULL_END