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

#import "PDSFileSession.h"
#import "PDSTransportClient.h"
#import "PDSMacro.h"
#import "PDSTaskStorageClient.h"
#import "PDSDownloadUrlRequest.h"
#import "PDSAPICreateFileRequest.h"
#import "PDSAPICompleteFileRequest.h"
#import "PDSAPIGetUploadUrlRequest.h"
#import "PDSAPIGetUploadUrlResponse.h"
#import "PDSAPIGetDownloadUrlResponse.h"
#import "PDSAPIGetDownloadUrlRequest.h"
#import "PDSAPIGetFileRequest.h"
#import "PDSAPIGetFileResponse.h"
#import "PDSAPIUpdateFileRequest.h"
#import "PDSAPIUpdateFileResponse.h"
#import "PDSAPIDeleteFileRequest.h"
#import "PDSAPIDeleteFileResponse.h"
#import "PDSAPIRecyclebinFileRequest.h"
#import "PDSAPIRecyclebinFileResponse.h"
#import "PDSAPIGetAsyncTaskResponse.h"
#import "PDSAPIGetAsyncTaskRequest.h"
#import "PDSAPISearchFileRequest.h"
#import "PDSAPIMoveFileRequest.h"
#import "PDSAPICopyFileRequest.h"
#import "PDSAPIListFileRequest.h"
#import "PDSUploadTask.h"
#import "PDSTaskStorageClient.h"

@implementation PDSFileSession

- (PDSDownloadTask *)downloadUrl:(PDSDownloadUrlRequest *)request taskIdentifier:(NSString *_Nullable)taskIdentifier {
    return [self.transportClient requestDownload:request taskIdentifier:taskIdentifier storageClient:self.storageClient];
}

- (PDSUploadTask *)uploadFile:(PDSUploadFileRequest *)request taskIdentifier:(NSString *_Nullable)taskIdentifier {
    return [self.transportClient requestUpload:request taskIdentifier:taskIdentifier storageClient:self.storageClient];
}

- (PDSUploadTask *)uploadPhotoAsset:(PDSUploadPhotoRequest *)request taskIdentifier:(NSString *)taskIdentifier {
    return [self.transportClient requestUploadPhoto:request taskIdentifier:taskIdentifier storageClient:self.storageClient];
}

- (void)cleanUploadTaskWithTaskIdentifier:(NSString *)taskIdentifier {
    [self cleanUploadTaskWithTaskIdentifier:taskIdentifier force:NO];
}

- (void)cleanUploadTaskWithTaskIdentifier:(NSString *)taskIdentifier force:(BOOL)force {
    if (PDSIsEmpty(taskIdentifier)) {
        return;
    }
    [self.storageClient cleanUploadTaskInfoWithIdentifier:taskIdentifier force:force];
}

- (void)cleanDownloadTaskWithTaskIdentifier:(NSString *)taskIdentifier {
    if (PDSIsEmpty(taskIdentifier)) {
        return;
    }
    [self.storageClient cleanDownloadTaskInfoWithIdentifier:taskIdentifier];
}


#pragma mark - File API
- (PDSAPIRequestTask<PDSAPICreateFileResponse *> *)createFile:(PDSAPICreateFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPICompleteFileResponse *> *)completeFile:(PDSAPICompleteFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetUploadUrlResponse *> *)getUploadUrl:(PDSAPIGetUploadUrlRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetDownloadUrlResponse *> *)getDownloadUrl:(PDSAPIGetDownloadUrlRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetFileResponse *> *)getFile:(PDSAPIGetFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIUpdateFileResponse *> *)updateFile:(PDSAPIUpdateFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIDeleteFileResponse *> *)deleteFile:(PDSAPIDeleteFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetAsyncTaskResponse *> *)getAsyncTask:(PDSAPIGetAsyncTaskRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPISearchFileResponse *> *)searchFile:(PDSAPISearchFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIMoveFileResponse *> *)moveFile:(PDSAPIMoveFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPICopyFileResponse *> *)copyFile:(PDSAPICopyFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIListFileResponse *> *)listFile:(PDSAPIListFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIRecyclebinFileResponse *> *)recyclebinFile:(PDSAPIRecyclebinFileRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

@end
