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

@class PDSFileSubSection;
@class PDSTaskFileSectionInfo;
@class PDSAPIUploadFilePartInfoItem;

NS_ASSUME_NONNULL_BEGIN

@protocol PDSTaskFileSectionInfoDelegate <NSObject>
- (void)fileSubSectionsChanged:(NSArray <PDSFileSubSection *> *)fileSections forFileSectionInfo:(PDSTaskFileSectionInfo *)fileSectionInfo;
@end

@interface PDSTaskFileSectionInfo : NSObject
@property(nonatomic, weak) id <PDSTaskFileSectionInfoDelegate> delegate;
/**
 * 分片对应的任务ID，如果存在的话,否则返回nil
 */
@property(nonatomic, copy, readonly) NSString *taskIdentifier;
/**
 * 分片大小，单位为byte
 */
@property(nonatomic, assign, readonly) uint64_t sectionSize;
/**
 * 文件总的大小，单位为byte
 */
@property(nonatomic, assign, readonly) uint64_t fileSize;
/**
 * 分片数量
 */
@property(nonatomic, assign, readonly) NSUInteger sectionCount;
/**
 * 已经处理的数据
 */
@property(nonatomic, assign, readonly) uint64_t committed;

/**
 * 是否已经全部处理完成
 */
@property(nonatomic, readonly) BOOL isFinished;

/**
 * 文件对应的ID
 */
@property(nonatomic, copy) NSString *fileID;

/**
 * 上传ID
 */
@property(nonatomic, copy) NSString *uploadID;

- (instancetype)initWithTaskIdentifier:(NSString *)taskIdentifier fileSize:(uint64_t)fileSize sectionSize:(uint64_t)sectionSize;

- (PDSFileSubSection *)subSectionAtIndex:(NSUInteger)index;

- (id)initWithTaskIdentifier:(NSString *)taskIdentifier fileSize:(uint64_t)fileSize sectionSize:(uint64_t)sectionSize fileID:(NSString *)fileId uploadID:(NSString *_Nullable)uploadId subSections:(NSArray<PDSFileSubSection *> *)subSections;

- (BOOL)updateSubSection:(PDSFileSubSection *)subSection;

- (void)updateSubSections:(BOOL (^)(PDSFileSubSection *))update;

- (PDSFileSubSection *)getNextAvailableSection;

- (NSArray<PDSFileSubSection *> *)getNextAvailableSections:(NSUInteger)count;

- (NSArray<PDSAPIUploadFilePartInfoItem *> *)partInfoItems;
@end

NS_ASSUME_NONNULL_END