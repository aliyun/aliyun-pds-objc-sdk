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

NS_ASSUME_NONNULL_BEGIN

@interface PDSFileMetadata : NSObject

//文件ID
@property(nonatomic, copy) NSString *fileID;

//版本ID
@property(nonatomic, copy) NSString *revisionID;

//文件名
@property(nonatomic, copy) NSString *fileName;

//文件本地保存的路径,仅针对下载文件返回数据有效
@property(nonatomic, copy) NSString *filePath;

//文件所在的磁盘ID，仅针对上传文件有效
@property(nonatomic, copy) NSString *driveID;

//文件的上传ID，仅针对上传文件有效
@property(nonatomic, copy) NSString *uploadID;

- (instancetype)initWithFileID:(NSString *)fileID revisionID:(NSString *)revisionID fileName:(NSString *)fileName
                      filePath:(NSString * _Nullable)filePath driveID:(NSString *)driveID uploadID:(NSString * _Nullable)uploadID;

@end

NS_ASSUME_NONNULL_END
