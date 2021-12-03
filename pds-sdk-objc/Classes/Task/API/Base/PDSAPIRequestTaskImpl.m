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

#import "PDSAPIRequestTaskImpl.h"
#import "PDSAPIRequest.h"
#import "PDSSessionDelegate.h"
#import "PDSRequestError.h"
#import "PDSTask+Internal.h"
#import <extobjc/EXTobjc.h>

@interface PDSAPIRequestTaskImpl ()
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, weak) PDSSessionDelegate *delegate;
@property(nonatomic, copy) PDSURLSessionTaskCreationBlock sessionTaskCreationBlock;
@property(nonatomic, strong) NSURLSessionTask *sessionTask;
@property(nonatomic, strong) dispatch_queue_t serialQueue;
@property(nonatomic, assign) BOOL cancelled;
@property(nonatomic, assign) BOOL suspended;
@property(nonatomic, assign) BOOL started;
@end

@implementation PDSAPIRequestTaskImpl {
    PDSAPIResponseBlock _responseBlock;
    PDSAPIResponseBlockStorage _storageBlock;
}
- (id)initWithRequest:(PDSAPIRequest *)request sessionTaskCreateBlock:(PDSURLSessionTaskCreationBlock)sessionTaskCreateBlock session:(NSURLSession *)session sessionDelegate:(PDSSessionDelegate *)delegate {
    self = [super init];
    if (self) {
        self.request = request;
        self.session = session;
        self.delegate = delegate;
        self.sessionTaskCreationBlock = sessionTaskCreateBlock;
        [self setup];
    }
    return self;
}

- (void)setup {
    dispatch_queue_attr_t qosAttribute =
            dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
    self.serialQueue =
            dispatch_queue_create("com.aliyun.pds.apiRequest.queue", qosAttribute);
}

#pragma mark Task Control

- (void)cancel {
    dispatch_async(_serialQueue, ^{
        self.cancelled = YES;
        [self.sessionTask cancel];
    });
}

- (void)suspend {
    dispatch_async(_serialQueue, ^{
        self.suspended = YES;
        [self.sessionTask suspend];
    });
}

- (void)resume {
    dispatch_async(_serialQueue, ^{
        if (self.started) {
            [self.sessionTask resume];
        } else {
            self.started = YES;
            [self _start];
        }
    });
}

- (void)start {
    [self resume];
}

- (PDSTask *)restart {
    PDSAPIRequestTaskImpl *requestTask = [[PDSAPIRequestTaskImpl alloc] initWithRequest:self.request
                                                               sessionTaskCreateBlock:_sessionTaskCreationBlock
                                                                              session:_session
                                                                      sessionDelegate:_delegate];
    requestTask.retryCount += 1;
    [requestTask setResponseBlock:_responseBlock];
    [requestTask resume];
    return requestTask;
}

- (void)_start {
    [self initSessionTask];
}

- (void)initSessionTask {
    _sessionTask = self.sessionTaskCreationBlock();
    [self setResponseBlockHandlerIfNecessary];
    if (_cancelled) {
        [_sessionTask cancel];
    } else if (_suspended) {
        [_sessionTask suspend];
    } else if (_started) {
        [_sessionTask resume];
    }
}

- (void)setResponseBlockHandlerIfNecessary {
    if (_sessionTask == nil || _responseBlock == nil) {
        return;
    }
    [_delegate addAPIResponseHandlerForTaskWithIdentifier:_sessionTask.taskIdentifier
                                                  session:_session
                                          ResponseHandler:_storageBlock
                                     responseHandlerQueue:_queue];
}

- (PDSAPIRequestTask *)setResponseBlock:(PDSAPIResponseBlock)responseBlock {
    return [self setResponseBlock:responseBlock queue:nil];
}

- (PDSAPIRequestTaskImpl *)setResponseBlock:(PDSAPIResponseBlock)responseBlock queue:(NSOperationQueue *_Nullable)queue {
    @weakify(self);
    dispatch_async(_serialQueue, ^{
        @strongify(self);
        self->_queue = queue;
        self->_responseBlock = responseBlock;
        PDSAPIResponseBlockStorage storageBlock = [self storageBlockWithResponseBlock:responseBlock];
        self->_storageBlock = storageBlock;
        [self setResponseBlockHandlerIfNecessary];
    });
    return self;
}


@end
