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

#import "PDSFileSubSection.h"


@implementation PDSFileSubSection {

}
- (instancetype)initWithIdentifier:(NSString *)identifier index:(NSUInteger)index size:(uint64_t)size offset:(uint64_t)offset taskIdentifier:(NSString *)taskIdentifier {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _taskIdentifier = taskIdentifier;
        _size = size;
        _offset = offset;
        _index = index;
    }

    return self;
}

#pragma mark Properties

- (BOOL)isFinished {
    if (self.size == 0) {
        return YES;
    }
    /**这里额外加入一个confirmed字段进行完成确认
     * 是因为在上传文件这边发现iOS的网络库存在进度回调返回数据bytes已经上传，但是实际接口response返回超时,服务端也没有收到数据的情况,
     * 这种情况下committed = size，客户端认为已经完成上传，但是实际上服务端根本没收到数据,导致数据丢失
     */
    return self.committed >= self.size && self.confirmed;
}

- (uint64_t)seekOffset {
    return self.offset + self.committed;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    PDSFileSubSection *otherSection = other;
    return [self.outputUrl isEqualToString:otherSection.outputUrl] &&
            self.committed == otherSection.committed &&
            [self.taskIdentifier isEqualToString:otherSection.taskIdentifier] &&
            [self.identifier isEqualToString:otherSection.identifier] &&
            self.index == otherSection.index &&
            self.confirmed == otherSection.confirmed;
}


#pragma mark Class Method

+ (NSArray *)buildSubSectionsFromFileSize:(uint64_t)totalSize sectionSize:(uint64_t)sectionSize taskIdentifier:(NSString *)taskIdentifier {
    NSUInteger sectionCount = (totalSize % sectionSize == 0) ? (totalSize / sectionSize) : (totalSize / (sectionSize) + 1);

    NSMutableArray<PDSFileSubSection *> *sections = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < sectionCount; i++) {
        NSString *identifier = [NSUUID UUID].UUIDString;
        uint64_t offset = i * sectionSize;
        uint64_t size = 0;
        if (i != sectionCount - 1) {
            size = sectionSize;
        } else {
            size = totalSize - offset;
        }
        PDSFileSubSection *section = [[PDSFileSubSection alloc] initWithIdentifier:identifier index:i size:size offset:offset taskIdentifier:taskIdentifier];
        [sections addObject:section];
    }
    return sections.copy;
}

-(id)copyWithZone:(NSZone *)zone {
    PDSFileSubSection *copied = [[PDSFileSubSection allocWithZone:zone] initWithIdentifier:self.identifier
                                                                      index:self.index
                                                                       size:self.size
                                                                     offset:self.offset
                                                             taskIdentifier:self.taskIdentifier];
    copied.committed = self.committed;
    copied.outputUrl = self.outputUrl;
    copied.confirmed = self.confirmed;
    return copied;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"PDSFileSubSection: taskId:%@,index:%ld,size:%llu,committed:%llu,offset:%llu,url:%@",self.taskIdentifier,self.index,self.size,self.committed,self.offset,self.outputUrl];
}
@end
