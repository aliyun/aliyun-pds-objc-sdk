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

@class FMDatabaseQueue;

NS_ASSUME_NONNULL_BEGIN


@interface PDSTaskStorageClient : NSObject
- (instancetype)initWithDBName:(NSString *)dbName;

- (void)getUploadTaskInfoWithId:(NSString *)taskIdentifier completion:(PDSTaskStorageGetInfoCompletion)completion;

- (void)setFileSubSections:(NSArray<PDSFileSubSection *> * _Nullable)fileSubSections uploadTaskInfo:(id<PDSTaskStorageInfo>)taskInfo;

- (void)setFileSubSections:(NSArray<PDSFileSubSection *> *)fileSubSections forTaskIdentifier:(NSString *)taskIdentifier;

- (void)getDownloadTaskInfoWithId:(NSString *)taskIdentifier completion:(PDSTaskStorageGetInfoCompletion)completion;

- (void)setFileSubSections:(NSArray<PDSFileSubSection *> *)fileSubSections downloadTaskInfo:(id<PDSTaskStorageInfo>)taskInfo;

- (void)cleanUploadTaskInfoWithIdentifier:(NSString *)taskIdentifier force:(BOOL)force;

- (void)cleanDownloadTaskInfoWithIdentifier:(NSString *)taskIdentifier;

@end

NS_ASSUME_NONNULL_END
