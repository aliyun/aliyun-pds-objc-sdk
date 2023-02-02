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
#import <PDS_SDK/PDSTypes.h>
#import <PDS_SDK/PDSInternalTypes.h>
#import <PDS_SDK/PDSCompletionData.h>

@class PDSProgressData;


@interface PDSSessionData : NSObject
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, PDSDownloadDataReceivedBlock> *dataReceiveHandlers;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSOperationQueue * > *dataReceiveHandlersQueues;

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, PDSDownloadResponseBlockStorage > *downloadHandlers;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, PDSUploadResponseBlockStorage > *uploadHandlers;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, PDSAPIResponseBlockStorage > *apiResponseHandlers;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSOperationQueue * > *responseHandlerQueues;

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, PDSProgressData *> *progressData;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, PDSProgressBlock > *progressHandlers;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSOperationQueue * > *progressHandlerQueues;

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableData *> *responsesData;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, PDSCompletionData *> *completionData;

- (instancetype)initWithSessionId:(NSString *)sessionId;

@end
