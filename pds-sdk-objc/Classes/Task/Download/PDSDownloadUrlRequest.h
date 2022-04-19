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
#import <PDS_SDK/PDSRequest.h>
#import <PDS_SDK/PDSFileHash.h>

@interface PDSDownloadUrlRequest : PDSRequest
// 下载链接
@property(nonatomic, copy, readonly) NSString *downloadUrl;
//文件的保存路径，如果对应的文件存储的目录不存在，SDK内部会自动创建
@property(nonatomic, copy, readonly) NSString *destination;
//下载文件的相对路径
@property(nonatomic, readonly) NSString *relativeDestination;
// 文件大小
@property(nonatomic, assign, readonly) uint64_t fileSize;
// 文件唯一标识
@property(nonatomic, copy, readonly) NSString *fileID;
//文件的哈希校验值
@property(nonatomic, copy, readonly) NSString *hashValue;
//文件的哈希校验算法
@property(nonatomic, assign, readonly) PDSFileHashType hashType;
//存储空间ID
@property(nonatomic, copy) NSString *driveID;
//分享空间ID
@property(nonatomic, copy) NSString *shareID;
/**
 * 初始化通过Url下载的任务请求
 * @param downloadUrl 下载链接，必填
 * @param destination 下载的文件保存地址，必填
 * @param userID 用户ID，可选，用于下载链接失效情况下自动刷新下载链接
 * @param fileSize 文件大小，必填
 * @param fileID 文件ID，可选，用于下载链接失效情况下自动刷新下载链接
 * @param hashValue 文件参数值，可选
 * @param hashType 文件校验算法，可选
 * @return 通过URL下载任务请求
 */
- (instancetype)initWithDownloadUrl:(NSString *)downloadUrl destination:(NSString *)destination fileSize:(uint64_t)fileSize fileID:(NSString *)fileID hashValue:(NSString *)hashValue hashType:(PDSFileHashType)hashType driveID:(NSString *)driveID shareID:(NSString *)shareID;

/**
 * 创建一个新的请求，使用传入的新的目标地址
 * @param destination
 * @return
 */
- (instancetype)requestWithNewDestination:(NSString *)destination;
@end
