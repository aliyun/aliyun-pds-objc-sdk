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
#import <PDS_SDK/PDSTask.h>
#import <PDS_SDK/PDSTypes.h>

@class PDSFileMetadata;
@class PDSRequestError;
@class PDSUploadFileRequest;

NS_ASSUME_NONNULL_BEGIN


@interface PDSUploadTask : PDSTask

typedef void (^PDSUploadResponseBlock)(PDSFileMetadata *_Nullable result,
        PDSRequestError *_Nullable requestError, NSString *taskIdentifier);

- (PDSUploadTask *)setResponseBlock:(PDSUploadResponseBlock)responseBlock;

- (PDSUploadTask *)setResponseBlock:(PDSUploadResponseBlock)responseBlock queue:(NSOperationQueue *_Nullable)queue;

- (PDSUploadTask *)setProgressBlock:(PDSProgressBlock)progressBlock;

- (PDSUploadTask *)setProgressBlock:(PDSProgressBlock)progressBlock queue:(NSOperationQueue *_Nullable)queue;

@end

NS_ASSUME_NONNULL_END
