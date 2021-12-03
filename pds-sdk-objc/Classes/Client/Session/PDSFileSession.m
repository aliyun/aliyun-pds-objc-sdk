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
#import "PDSAPIGetAsyncTaskResponse.h"
#import "PDSAPIGetAsyncTaskRequest.h"
#import "PDSAPISearchFileRequest.h"
#import "PDSAPIMoveFileRequest.h"
#import "PDSAPICopyFileRequest.h"

@implementation PDSFileSession

- (PDSDownloadUrlTask *)downloadUrl:(PDSDownloadUrlRequest *)request taskIdentifier:(NSString *_Nullable)taskIdentifier {
    return [self.client requestDownload:request taskIdentifier:taskIdentifier];
}

- (PDSUploadFileTask *)uploadFile:(PDSUploadFileRequest *)request taskIdentifier:(NSString *_Nullable)taskIdentifier {
    return [self.client requestUpload:request taskIdentifier:taskIdentifier];
}

- (void)cleanUploadTaskWithTaskIdentifier:(NSString *)taskIdentifier {
    if (PDSIsEmpty(taskIdentifier)) {
        return;
    }
    [[PDSTaskStorageClient sharedInstance] cleanUploadTaskInfoWithIdentifier:taskIdentifier];
}


- (PDSAPIRequestTask<PDSAPICreateFileResponse *> *)createFile:(PDSAPICreateFileRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPICompleteFileResponse *> *)completeFile:(PDSAPICompleteFileRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetUploadUrlResponse *> *)getUploadUrl:(PDSAPIGetUploadUrlRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetDownloadUrlResponse *> *)getDownloadUrl:(PDSAPIGetDownloadUrlRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetFileResponse *> *)getFile:(PDSAPIGetFileRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIUpdateFileResponse *> *)updateFile:(PDSAPIUpdateFileRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIDeleteFileResponse *> *)deleteFile:(PDSAPIDeleteFileRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetAsyncTaskResponse *> *)getAsyncTask:(PDSAPIGetAsyncTaskRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPISearchFileResponse *> *)searchFile:(PDSAPISearchFileRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIMoveFileResponse *> *)moveFile:(PDSAPIMoveFileRequest *)request {
    return [self.client requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPICopyFileResponse *> *)copyFile:(PDSAPICopyFileRequest *)request {
    return [self.client requestSDAPIRequest:request];
}
@end
