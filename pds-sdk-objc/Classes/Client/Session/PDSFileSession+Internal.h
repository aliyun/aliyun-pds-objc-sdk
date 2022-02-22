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
#import "PDSFileSession.h"

@interface PDSFileSession (Internal)
/// 创建下载Live Photo任务，仅用于PDS业务内部使用，外部客户请不要调用这个方法
/// @param request 下载live photo任务请求
/// @param taskIdentifier 任务ID,SDK会通过taskID判断之前是否创建过下载任务，如果创建过会尝试恢复之前的上传记录
/// @return 下载任务
- (PDSDownloadTask *_Nullable)downloadLivePhoto:(PDSDownloadUrlRequest *_Nullable)request taskIdentifier:(NSString *_Nullable)taskIdentifier;

/// 创建下载Live Photo任务，仅用于PDS业务内部使用，外部客户请不要调用这个方法
/// @param request 下载live photo任务请求
/// @param taskIdentifier 任务ID,SDK会通过taskID判断之前是否创建过下载任务，如果创建过会尝试恢复之前的上传记录
/// @return 下载任务
- (PDSUploadTask *_Nullable)uploadLivePhoto:(PDSUploadPhotoRequest *_Nullable)request taskIdentifier:(NSString *_Nullable)taskIdentifier;
@end