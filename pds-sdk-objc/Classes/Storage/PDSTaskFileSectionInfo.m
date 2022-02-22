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

#import "PDSTaskFileSectionInfo.h"
#import "PDSFileSubSection.h"
#import "NSArray+PDS.h"
#import "PDSLogger.h"
#import "PDSAPIUploadFilePartInfoItem.h"

@interface PDSTaskFileSectionInfo ()
@property(nonatomic, strong) NSArray<PDSFileSubSection *> *subSections;
@property(nonatomic, strong) NSMutableArray *availableSectionIndexes;
@property(nonatomic, readwrite) BOOL isFinished;
/**
 * 已经处理的数据
 */
@property(nonatomic, assign, readwrite) uint64_t committed;
@end

@implementation PDSTaskFileSectionInfo {

}

- (instancetype)initWithTaskIdentifier:(NSString *)taskIdentifier fileSize:(uint64_t)fileSize sectionSize:(uint64_t)sectionSize {
    self = [self init];
    if (self) {
        _taskIdentifier = taskIdentifier;
        _fileSize = fileSize;
        _sectionSize = sectionSize;
        [self setup];
    }
    return self;
}

- (id)initWithTaskIdentifier:(NSString *)taskIdentifier fileSize:(uint64_t)fileSize sectionSize:(uint64_t)sectionSize fileID:(NSString *)fileId uploadID:(NSString *)uploadId subSections:(NSArray<PDSFileSubSection *> *)subSections {
    self = [super init];
    if (self) {
        _taskIdentifier = taskIdentifier;
        _fileSize = fileSize;
        _sectionSize = sectionSize;
        _fileID = fileId;
        _uploadID = uploadId;
        _subSections = subSections;
        [self setupSubSections];
    }
    return self;
}

- (void)setup {
    if (self.fileSize == 0) {
        self.subSections = nil;
        self.availableSectionIndexes = nil;
        return;
    } else {
        self.subSections = [PDSFileSubSection buildSubSectionsFromFileSize:self.fileSize
                                                              sectionSize:self.sectionSize
                                                           taskIdentifier:self.taskIdentifier];
        [self setupSubSections];
    }
}

- (void)setupSubSections {
    //检查哪些分片还没有处理完成
    NSMutableArray *availableSectionIndexes = [[NSMutableArray alloc] init];
    __block uint64_t committed = 0;
    [self.subSections enumerateObjectsUsingBlock:^(PDSFileSubSection *subSection, NSUInteger idx, BOOL *stop) {
        if (!subSection.isFinished) {
            subSection.committed = 0;//如果上次没有上传完成，那么从头开始进行上传
            [availableSectionIndexes addObject:@(subSection.index)];
        } else {//上传完成，计入总共的上传完成数据中
            committed += subSection.committed;
        }
    }];
    self.committed = committed;
    self.availableSectionIndexes = availableSectionIndexes;
}

#pragma mark Public Method

- (PDSFileSubSection *)subSectionAtIndex:(NSUInteger)index {
    @synchronized (self) {
        return [[self.subSections pds_objectAtIndex:index] copy];
    }
}

- (PDSFileSubSection *)getNextAvailableSection {
    @synchronized (self) {
        NSNumber *nextIndex = self.availableSectionIndexes.firstObject;
        if (!nextIndex) {
            return nil;
        }
        PDSFileSubSection *nextAvailableSection = [self subSectionAtIndex:[nextIndex unsignedIntegerValue]];
        if (!nextAvailableSection) {
            [self.availableSectionIndexes removeObject:nextIndex];
            return [self getNextAvailableSection];
        }
        return nextAvailableSection;
    }
}

- (NSArray<PDSFileSubSection *> *)getNextAvailableSections:(NSUInteger)count {
    if (count == 0) {
        return nil;
    }
    NSArray *resultIndexes = nil;
    @synchronized (self) {
        if (count > self.availableSectionIndexes.count) {
            resultIndexes = [self.availableSectionIndexes copy];
        } else {
            resultIndexes = [self.availableSectionIndexes subarrayWithRange:NSMakeRange(0, count)];
        }
        NSMutableArray *resultSubSections = [[NSMutableArray alloc] init];
        [resultIndexes enumerateObjectsUsingBlock:^(NSNumber *index, NSUInteger idx, BOOL *stop) {
            PDSFileSubSection *subSection = [self subSectionAtIndex:[index unsignedIntegerValue]];
            if (subSection) {
                [PDSLogger logDebug:[NSString stringWithFormat:@"获取待下载的分片index:%d",index.unsignedIntValue]];
                [resultSubSections addObject:subSection];
            }
        }];
        return [resultSubSections copy];
    }
}


- (BOOL)updateSubSection:(PDSFileSubSection *)subSection {
    @synchronized (self) {
        PDSFileSubSection *toUpdatedSubSection = [self.subSections pds_objectAtIndex:subSection.index];
        if (!toUpdatedSubSection) {
            return NO;
        }
        //更新文件总的处理字节数
        self.committed -= toUpdatedSubSection.committed;
        self.committed += subSection.committed;
        //更新对应的分块信息
        toUpdatedSubSection.committed = subSection.committed;
        toUpdatedSubSection.outputUrl = subSection.outputUrl;
        toUpdatedSubSection.confirmed = subSection.confirmed;
        if ([self.delegate respondsToSelector:@selector(fileSubSectionsChanged:forFileSectionInfo:)]) {
            [self.delegate fileSubSectionsChanged:@[toUpdatedSubSection] forFileSectionInfo:self];
        }
        if (toUpdatedSubSection.isFinished) {
            [self.availableSectionIndexes removeObject:@(toUpdatedSubSection.index)];
            [PDSLogger logDebug:[NSString stringWithFormat:@"移除已经处理的分片index:%ld,剩余待处理分片数量:%ld",
                                 (unsigned long)toUpdatedSubSection.index,self.availableSectionIndexes.count]];
        }
    }
    return YES;
}


- (void)updateSubSections:(BOOL (^)(PDSFileSubSection *))update {
    NSMutableArray *changedSubSections = [[NSMutableArray alloc] init];
    if (update) {
        @synchronized (self) {
            [self.subSections enumerateObjectsUsingBlock:^(PDSFileSubSection *subSection, NSUInteger idx, BOOL *stop) {
                uint64_t previousSubSectionCommitted = subSection.committed;
                BOOL changed = update(subSection);
                if (changed) {
                    //更新文件总的处理字节数
                    self.committed -= previousSubSectionCommitted;
                    self.committed += subSection.committed;
                    //记录哪些分片更新了，方便之后批量插入数据库
                    [changedSubSections addObject:subSection];
                }
            }];
        }
        if (changedSubSections.count && [self.delegate respondsToSelector:@selector(fileSubSectionsChanged:forFileSectionInfo:)]) {
            [self.delegate fileSubSectionsChanged:changedSubSections forFileSectionInfo:self];
        }
    }
}

#pragma mark Properties

- (BOOL)isFinished {
    @synchronized (self) {
        return self.availableSectionIndexes.count == 0;
    }
}

- (NSUInteger)sectionCount {
    @synchronized (self) {
        return self.subSections.count;
    }
}

- (NSArray<PDSAPIUploadFilePartInfoItem *> *)partInfoItems {
    NSMutableArray *partInfoItems = [[NSMutableArray alloc] init];
    [self.subSections enumerateObjectsUsingBlock:^(PDSFileSubSection *subSection, NSUInteger idx, BOOL *stop) {
        PDSAPIUploadFilePartInfoItem *partInfoItem = [[PDSAPIUploadFilePartInfoItem alloc] initWithPartNumber:subSection.index
                                                                                                    uploadUrl:subSection.outputUrl];
        [partInfoItems addObject:partInfoItem];
    }];
    return [partInfoItems copy];
}

@end
