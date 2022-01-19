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

@interface NSFileManager (PDS)
/// 返回指定文件的大小,如果文件不存在返回0。单位为byte
/// @param filePath 文件路径
/// @return 文件大小
- (uint64_t)pds_fileSizeForPath:(NSString *)filePath;

/// 返回指定路径的文件类型，如果文件不存在，那么返回nil
/// @param filePath 文件路径
/// @return 文件类型
- (NSString *)pds_mimeTypeForPath:(NSString *)filePath;

/// 返回当前磁盘剩余空间，单位为byte
/// @return 当前磁盘的剩余空间
- (uint64_t)pds_diskAvailableCapacity;

 ///
 /// @param filePath
 /// @return

/// 检查文件路径对应的文件是否存在，如果存在的话自动 + 1，最多加100
/// @param filePath 要检查的文件路径的引用
/// @return 是否命名成功
- (BOOL)pds_autoRenameFile:(NSString **)filePath;

/// 删除指定路径的文件
/// @param filePath 文件路径
/// @return 是否删除文件成功,当文件不存在的时候依然返回YES
- (BOOL)pds_removeItemAtPath:(NSString *)filePath;
@end
