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

#import "PDSTaskStorageClient.h"
#import "FMDatabaseQueue.h"
#import "PDSUploadTaskStorage.h"
#import "PDSDownloadTaskStorage.h"
#import <fmdb/FMDB.h>

static NSString *const kPDSDBName = @"PDSSDK.db";

@interface PDSTaskStorageClient ()
@property(nonatomic, strong) FMDatabaseQueue *dbQueue;
@property(nonatomic, strong) PDSUploadTaskStorage *uploadTaskStorage;
@property(nonatomic, strong) PDSDownloadTaskStorage *downloadTaskStorage;
@end

@implementation PDSTaskStorageClient

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }

    return self;
}

- (void)setup {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dbPath = [documentPath stringByAppendingPathComponent:kPDSDBName];
    self.dbQueue = [[FMDatabaseQueue alloc] initWithPath:dbPath];

    self.uploadTaskStorage = [[PDSUploadTaskStorage alloc] init];
    [self.uploadTaskStorage setupWithDBQueue:self.dbQueue];

//    self.downloadTaskStorage = [[PDSDownloadTaskStorage alloc] init];
//    [self.downloadTaskStorage setupWithDBQueue:self.dbQueue];
}

- (void)getUploadTaskInfoWithId:(NSString *)taskIdentifier completion:(PDSTaskStorageGetInfoCompletion)completion {
    [self.uploadTaskStorage getTaskInfoWithIdentifier:taskIdentifier completion:completion];
}

- (void)setFileSubSections:(NSArray<PDSFileSubSection *> *)fileSubSections uploadTaskInfo:(id<PDSTaskStorageInfo>)taskInfo {
    [self.uploadTaskStorage setFileSections:fileSubSections withTaskStorageInfo:taskInfo];
}


- (void)cleanUploadTaskInfoWithIdentifier:(NSString *)taskIdentifier {
    [self.uploadTaskStorage deleteTaskInfoWithIdentifier:taskIdentifier];
}

- (void)setFileSubSections:(NSArray<PDSFileSubSection *> *)fileSubSections forTaskIdentifier:(NSString *)taskIdentifier {
    [self.uploadTaskStorage setFileSubSections:fileSubSections forTaskIdentifier:taskIdentifier];
}


@end
