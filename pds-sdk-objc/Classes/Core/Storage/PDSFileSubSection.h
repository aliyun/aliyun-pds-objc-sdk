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


@interface PDSFileSubSection : NSObject <NSCopying>
@property(nonatomic, copy, readonly) NSString *identifier;    //片的唯一标识
@property(nonatomic, copy) NSString *taskIdentifier;//分片所属的任务ID
@property(nonatomic, assign, readonly) NSUInteger index; //分片索引
@property(nonatomic, assign, readonly) uint64_t size;   //片的大小
@property(nonatomic, assign, readonly) uint64_t offset; //片开始的位置
@property(nonatomic, assign) uint64_t committed;//已经发送/下载的数据
@property(nonatomic, assign, readonly) BOOL isFinished;//分片是否已经处理完成(定义标准,处理的字节数大于等于总的字节数，同时confirmed为YES)
@property(nonatomic, assign) BOOL confirmed;//分片处理的接口是否已经返回确认
@property(nonatomic, assign, readonly) uint64_t seekOffset;//分片对应的文件偏移位置(分片开始位置+已经接收的数据大小)
@property(nonatomic, copy) NSString *outputUrl;//分片对应的链接,对于上传任务来说是服务端返回的各个分片的地址,对于下载任务来说是唯一的下载地址

- (instancetype)initWithIdentifier:(NSString *)identifier index:(NSUInteger)index size:(uint64_t)size offset:(uint64_t)offset taskIdentifier:(NSString *)taskIdentifier;

+ (NSArray *)buildSubSectionsFromFileSize:(uint64_t)totalSize sectionSize:(uint64_t)sectionSize taskIdentifier:(NSString *)taskIdentifier;
@end
