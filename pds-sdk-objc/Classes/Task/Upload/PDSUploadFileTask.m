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

#import "PDSTransportClient+Internal.h"
#import "PDSAPIResponse.h"
#import "PDSAPIRequest.h"
#import "PDSInternalTypes.h"
#import "PDSTransportClient.h"
#import "PDSAPIRequestTask.h"
#import "PDSUploadFileTask.h"
#import "PDSFileMetadata.h"
#import "PDSRequestError.h"
#import "PDSUploadFileRequest.h"
#import "PDSResponseError.h"
#import "PDSTask+Internal.h"


@implementation PDSUploadFileTask {

}

- (BOOL)isCancelled {
    return NO;
}

- (BOOL)isFinished {
    return NO;
}

- (PDSUploadFileTask *)setResponseBlock:(PDSUploadResponseBlock)responseBlock {
#pragma unused(responseBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (PDSUploadFileTask *)setResponseBlock:(PDSUploadResponseBlock)responseBlock queue:(NSOperationQueue *)queue {
#pragma unused(responseBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}


- (PDSUploadFileTask *)setProgressBlock:(PDSProgressBlock)progressBlock {
#pragma unused(progressBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (PDSUploadFileTask *)setProgressBlock:(PDSProgressBlock)progressBlock queue:(NSOperationQueue *)queue {
#pragma unused(progressBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}


@end