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
#import <PDS_SDK/PDSAPIRequestTask.h>
#import <PDS_SDK/PDSBaseSession.h>

NS_ASSUME_NONNULL_BEGIN

@class PDSTransportClient;
@class PDSDownloadTask;
@class PDSDownloadUrlRequest;
@class PDSAPICreateFileRequest;
@class PDSAPICreateFileResponse;
@class PDSAPICompleteFileResponse;
@class PDSAPICompleteFileRequest;
@class PDSUploadTask;
@class PDSUploadFileRequest;
@class PDSAPIGetUploadUrlRequest;
@class PDSAPIGetUploadUrlResponse;
@class PDSAPIGetDownloadUrlResponse;
@class PDSAPIGetDownloadUrlRequest;
@class PDSAPIGetFileRequest;
@class PDSAPIGetFileResponse;
@class PDSAPIUpdateFileRequest;
@class PDSAPIUpdateFileResponse;
@class PDSAPIDeleteFileRequest;
@class PDSAPIDeleteFileResponse;
@class PDSAPIGetAsyncTaskRequest;
@class PDSAPIGetAsyncTaskResponse;
@class PDSAPISearchFileRequest;
@class PDSAPISearchFileResponse;
@class PDSAPIMoveFileRequest;
@class PDSAPIMoveFileResponse;
@class PDSAPICopyFileRequest;
@class PDSAPICopyFileResponse;
@class PDSUploadPhotoRequest;
@class PDSAPIListFileResponse;
@class PDSAPIListFileRequest;

@interface PDSFileSession : PDSBaseSession

/// 通过URL创建下载任务
/// @param request 下载任务请求
/// @param taskIdentifier 任务ID,SDK会通过taskID判断之前是否创建过下载任务，如果创建过会尝试恢复之前的下载记录
/// @return 下载任务
- (PDSDownloadTask *)downloadUrl:(PDSDownloadUrlRequest *)request taskIdentifier:(NSString *_Nullable)taskIdentifier;

/// 创建上传文件任务
/// @param request 上传文件任务请求
/// @param taskIdentifier 任务ID,SDK会通过taskID判断之前是否创建过上传任务，如果创建过会尝试恢复之前的上传记录
/// @return 上传任务
- (PDSUploadTask *)uploadFile:(PDSUploadFileRequest *)request taskIdentifier:(NSString *_Nullable)taskIdentifier;

/// 创建上传照片任务
/// @param request 上传照片任务请求
/// @param taskIdentifier 任务ID,SDK会通过taskID判断之前是否创建过上传任务，如果创建过会尝试恢复之前的上传记录
- (PDSUploadTask *)uploadPhotoAsset:(PDSUploadPhotoRequest *)request taskIdentifier:(NSString *)taskIdentifier;

/// 清理上传任务信息
/// 主要用于App重启以后之前中断上传的任务存在一些本地数据和临时文件，如果需要移除任务的话需要调用这个接口清除对应的数据，避免占用
/// 额外的磁盘空间
/// @param taskIdentifier 任务ID
- (void)cleanUploadTaskWithTaskIdentifier:(NSString *)taskIdentifier;

/// 清理上传任务信息
/// 主要用于App重启以后之前中断上传的任务存在一些本地数据和临时文件，如果需要移除任务的话需要调用这个接口清除对应的数据，避免占用
/// 额外的磁盘空间
/// @param taskIdentifier 任务ID
/// @param force 是否强制删除上传文件，默认情况下SDK仅删除自身创建的临时上传文件，不会删除上传任务外部传入的文件
- (void)cleanUploadTaskWithTaskIdentifier:(NSString *)taskIdentifier force:(BOOL)force;

/// 清理下载任务信息
/// 主要用于App重启以后之前中断下载的任务存在一些本地数据和临时文件，如果需要移除任务的话需要调用这个接口清除对应的数据，避免占用
/// 额外的磁盘空间
/// @param taskIdentifier 任务ID
- (void)cleanDownloadTaskWithTaskIdentifier:(NSString *)taskIdentifier;

/// 创建文件接口
/// https://help.aliyun.com/document_detail/175927.html#h2-u521Bu5EFAu6587u4EF6u6216u8005u6587u4EF6u593914
/// @param request 创建文件接口请求
- (PDSAPIRequestTask<PDSAPICreateFileResponse *> *)createFile:(PDSAPICreateFileRequest *)request;

/// 文件上传完成以后调用完成接口
/// https://help.aliyun.com/document_detail/175927.html#h2-u5B8Cu6210u6587u4EF6u4E0Au4F2012
/// @param request 完成文件接口请求
- (PDSAPIRequestTask<PDSAPICompleteFileResponse *> *)completeFile:(PDSAPICompleteFileRequest *)request;

/// 刷新上传Url接口，当上传url过期时候调用这个接口获得新的上传Url
/// https://help.aliyun.com/document_detail/175927.html#h2-u83B7u53D6u6587u4EF6u5206u7247u7684u4E0Au4F20u5730u574021
/// @param request 刷新上传Url接口请求
- (PDSAPIRequestTask<PDSAPIGetUploadUrlResponse *> *)getUploadUrl:(PDSAPIGetUploadUrlRequest *)request;


/// 刷新下载Url接口，当下载url过期时候调用这个接口获得新的下载Url
/// https://help.aliyun.com/document_detail/175927.html#h2-u83B7u53D6u6587u4EF6u4E0Bu8F7Du5730u574019
/// @param request 刷新下载url接口请求
- (PDSAPIRequestTask<PDSAPIGetDownloadUrlResponse *> *)getDownloadUrl:(PDSAPIGetDownloadUrlRequest *)request;

/// 获取文件/文件夹信息接口
/// https://help.aliyun.com/document_detail/175927.html#h2-u83B7u53D6u6587u4EF6u6216u6587u4EF6u5939u4FE1u606F17
/// @param request 获取文件信息接口请求
- (PDSAPIRequestTask<PDSAPIGetFileResponse *> *)getFile:(PDSAPIGetFileRequest *)request;

/// 更新文件/文件夹信息接口
/// https://help.aliyun.com/document_detail/175927.html#h2-u66F4u65B0u6587u4EF6u6216u6587u4EF6u5939u4FE1u606F29
/// @param request 更新文件信息接口请求
- (PDSAPIRequestTask<PDSAPIUpdateFileResponse *> *)updateFile:(PDSAPIUpdateFileRequest *)request;

/// 删除文件/文件夹接口
/// https://help.aliyun.com/document_detail/175927.html#h2-u5220u9664u6587u4EF6u6216u6587u4EF6u593915
/// @param request 删除文件请求接口请求
- (PDSAPIRequestTask<PDSAPIDeleteFileResponse *> *)deleteFile:(PDSAPIDeleteFileRequest *)request;

/// 获取异步任务状态接口
/// https://help.aliyun.com/document_detail/175927.html#h2-u83B7u53D6u5F02u6B65u4EFBu52A1u4FE1u606F3
/// @param request 获取异步任务状态接口请求
- (PDSAPIRequestTask<PDSAPIGetAsyncTaskResponse *> *)getAsyncTask:(PDSAPIGetAsyncTaskRequest *)request;

/// 查找文件接口
/// https://help.aliyun.com/document_detail/175927.html#h2-u6587u4EF6u641Cu7D2228
/// @param request 查找文件接口请求
- (PDSAPIRequestTask<PDSAPISearchFileResponse *> *)searchFile:(PDSAPISearchFileRequest *)request;

/// 移动文件/文件夹接口
/// https://help.aliyun.com/document_detail/175927.html#h2-u79FBu52A8u6587u4EF6u6216u6587u4EF6u593926
/// @param request 异动文件接口请求
- (PDSAPIRequestTask<PDSAPIMoveFileResponse *> *)moveFile:(PDSAPIMoveFileRequest *)request;

/// 复制文件/文件夹接口
/// https://help.aliyun.com/document_detail/175927.html#h2-u62F7u8D1Du6587u4EF6u6216u6587u4EF6u593913
/// @param request 复制文件接口请求
- (PDSAPIRequestTask<PDSAPICopyFileResponse *> *)copyFile:(PDSAPICopyFileRequest *)request;

/// 通过URL创建下载任务
/// @param request 下载任务请求
/// @param taskIdentifier 任务ID,SDK会通过taskID判断之前是否创建过下载任务，如果创建过会尝试恢复之前的下载记录
/// @return 下载任务
- (PDSAPIRequestTask<PDSAPIListFileResponse *> *)listFile:(PDSAPIListFileRequest *)request;

@end

NS_ASSUME_NONNULL_END
