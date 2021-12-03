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

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPICopyFileRequest : PDSAPIRequest
//要拷贝的文件ID，必填
@property(nonatomic, copy) NSString *fileID;
//要操作的磁盘ID，必填
@property(nonatomic, copy) NSString *driveID;
//要拷贝的文件夹ID，必填
@property(nonatomic, copy) NSString *toParentFileID;
//要拷贝到的磁盘ID，必填
@property(nonatomic, copy) NSString *toDriveID;
//目标文件夹已经存在同名文件情况下是否自动重命名
@property(nonatomic, assign) BOOL autoRename;
//拷贝以后的文件名，必填
@property(nonatomic, copy) NSString *neoName;

- (instancetype)initWithFileID:(NSString *)fileID driveID:(NSString *)driveID toParentFileID:(NSString *)toParentFileID toDriveID:(NSString *_Nullable)toDriveID autoRename:(BOOL)autoRename newName:(NSString *)neoName;


@end

NS_ASSUME_NONNULL_END
