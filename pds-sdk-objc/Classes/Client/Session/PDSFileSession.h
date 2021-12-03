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
@class PDSDownloadUrlTask;
@class PDSDownloadUrlRequest;
@class PDSAPICreateFileRequest;
@class PDSAPICreateFileResponse;
@class PDSAPICompleteFileResponse;
@class PDSAPICompleteFileRequest;
@class PDSUploadFileTask;
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

@interface PDSFileSession : PDSBaseSession


/// 通过URL创建下载任务
/// @param request 下载任务请求
/// @param taskIdentifier SDK会通过taskID判断之前是否创建过下载任务，如果创建过会尝试恢复之前的下载记录
/// @return 下载任务
- (PDSDownloadUrlTask *)downloadUrl:(PDSDownloadUrlRequest *)request taskIdentifier:(NSString *_Nullable)taskIdentifier;

/// 创建上传任务
/// @param request 上传任务请求
/// @param taskIdentifier SDK会通过taskID判断之前是否创建过上传任务，如果创建过会尝试恢复之前的下载记录
/// @return 上传任务
- (PDSUploadFileTask *)uploadFile:(PDSUploadFileRequest *)request taskIdentifier:(NSString *_Nullable)taskIdentifier;

- (void)cleanUploadTaskWithTaskIdentifier:(NSString *)taskIdentifier;

- (PDSAPIRequestTask<PDSAPICreateFileResponse *> *)createFile:(PDSAPICreateFileRequest *)request;

- (PDSAPIRequestTask<PDSAPICompleteFileResponse *> *)completeFile:(PDSAPICompleteFileRequest *)request;

- (PDSAPIRequestTask<PDSAPIGetUploadUrlResponse *> *)getUploadUrl:(PDSAPIGetUploadUrlRequest *)request;

- (PDSAPIRequestTask<PDSAPIGetDownloadUrlResponse *> *)getDownloadUrl:(PDSAPIGetDownloadUrlRequest *)request;

- (PDSAPIRequestTask<PDSAPIGetFileResponse *> *)getFile:(PDSAPIGetFileRequest *)request;

- (PDSAPIRequestTask<PDSAPIUpdateFileResponse *> *)updateFile:(PDSAPIUpdateFileRequest *)request;

- (PDSAPIRequestTask<PDSAPIDeleteFileResponse *> *)deleteFile:(PDSAPIDeleteFileRequest *)request;

- (PDSAPIRequestTask<PDSAPIGetAsyncTaskResponse *> *)getAsyncTask:(PDSAPIGetAsyncTaskRequest *)request;

- (PDSAPIRequestTask<PDSAPISearchFileResponse *> *)searchFile:(PDSAPISearchFileRequest *)request;

- (PDSAPIRequestTask<PDSAPIMoveFileResponse *> *)moveFile:(PDSAPIMoveFileRequest *)request;

- (PDSAPIRequestTask<PDSAPICopyFileResponse *> *)copyFile:(PDSAPICopyFileRequest *)request;
@end

NS_ASSUME_NONNULL_END
