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

#import "PDSDownloadTask.h"
#import "PDSRequestError.h"
#import "PDSFileMetadata.h"

@interface PDSDownloadTask ()
@end

@implementation PDSDownloadTask {

}

- (void)cancel {
}

- (void)suspend {
}

- (void)resume {
}

- (void)start {
}

- (PDSDownloadTask *)setResponseBlock:(PDSDownloadResponseBlock)responseBlock {
#pragma unused(responseBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (PDSDownloadTask *)setResponseBlock:(PDSDownloadResponseBlock)responseBlock queue:(NSOperationQueue *)queue {
#pragma unused(responseBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (PDSDownloadTask *)setProgressBlock:(PDSProgressBlock)progressBlock {
#pragma unused(progressBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (PDSDownloadTask *)setProgressBlock:(PDSProgressBlock)progressBlock queue:(NSOperationQueue *)queue {
#pragma unused(progressBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
    nil;
}


@end