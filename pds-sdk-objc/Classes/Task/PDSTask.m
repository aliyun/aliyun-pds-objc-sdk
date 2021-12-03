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

#import "PDSInternalParallelDownloadTask.h"
#import "PDSTaskValidatorChecker.h"
#import "PDSTaskDiskCapacityValidator.h"
#import "PDSTaskFolderExistValidator.h"
#import "PDSTaskValidator.h"
#import "PDSDownloadUrlTaskImpl.h"
#import "PDSTask.h"

@interface PDSTask ()
@end

@implementation PDSTask

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskIdentifier = [[NSUUID UUID].UUIDString copy];
    }
    return self;
}

- (id)initWithIdentifier:(NSString *)identifier {
    self = [self init];
    if (identifier) {
        _taskIdentifier = identifier;
    }
    return self;
}

- (void)cancel {
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (void)suspend {
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (void)resume {
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (void)start {
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (PDSTask *)restart {
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (BOOL)isCancelled {
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (BOOL)isFinished {
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

@end
