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

#import "PDSSessionData.h"
#import "PDSProgressData.h"

@interface PDSSessionData ()

@property(nonatomic, copy) NSString *sessionId;
@end

@implementation PDSSessionData {
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }

    return self;
}

- (void)setup {
    self.dataReceiveHandlers = [[NSMutableDictionary alloc] init];
    self.dataReceiveHandlersQueues = [[NSMutableDictionary alloc] init];

    self.downloadHandlers = [[NSMutableDictionary alloc] init];
    self.uploadHandlers = [[NSMutableDictionary alloc] init];
    self.apiResponseHandlers = [[NSMutableDictionary alloc] init];
    self.responseHandlerQueues = [[NSMutableDictionary alloc] init];

    self.progressData = [[NSMutableDictionary alloc] init];
    self.progressHandlers = [[NSMutableDictionary alloc] init];
    self.progressHandlerQueues = [[NSMutableDictionary alloc] init];

    self.responsesData = [[NSMutableDictionary alloc] init];
    self.completionData = [[NSMutableDictionary alloc] init];
}

- (instancetype)initWithSessionId:(NSString *)sessionId {
    self = [self init];
    if (self) {
        self.sessionId = sessionId;
    }
    return self;
}

#pragma mark

@end