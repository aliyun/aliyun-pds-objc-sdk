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
#import <PDS_SDK/PDSInternalTask.h>
#import <PDS_SDK/PDSFileHash.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PDSInternalHashTaskResponseBlock)(BOOL success, NSString *hashResult, NSError *error);

typedef void (^PDSInternalHashTaskProgressBlock)(int64_t totalBytesCalculated, int64_t totalBytesExpectedToCalculated);

typedef NS_ENUM(NSInteger, PDSFileHashCalculateType) {
    PDSFileHashCalculateTypeFull,//全量hash
    PDSFileHashCalculateTypeOnly1K,//只计算头部的1KHash
};

@interface PDSInternalHashTask : NSObject <PDSInternalTask>
@property(nonatomic, copy, readonly) NSString *filePath;
@property(nonatomic, assign, readonly) PDSFileHashType hashType;
@property(nonatomic, copy, readonly) NSString *hashValue;
@property(nonatomic, copy) PDSInternalHashTaskResponseBlock responseBlock;
@property(nonatomic, copy) PDSInternalHashTaskProgressBlock progressBlock;

@property(nonatomic, readonly) BOOL finished;

- (instancetype)initWithFilePath:(NSString *)filePath hashType:(PDSFileHashType)hashType hashValue:(NSString *_Nullable)hashValue calculateType:(PDSFileHashCalculateType)calculateType;

- (instancetype)initWithFilePath:(NSString *)filePath hashType:(PDSFileHashType)hashType hashValue:(NSString *_Nullable)hashValue;

- (void)setResponseBlock:(PDSInternalHashTaskResponseBlock)responseBlock;

- (void)setResponseBlock:(PDSInternalHashTaskResponseBlock)responseBlock queue:(NSOperationQueue *_Nullable)queue;

@end

NS_ASSUME_NONNULL_END
