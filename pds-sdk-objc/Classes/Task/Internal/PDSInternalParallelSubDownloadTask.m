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

#import "PDSInternalParallelSubDownloadTask.h"
#import "PDSSessionDelegate.h"
#import "PDSDownloadUrlRequest.h"
#import "PDSFileSubSection.h"
#import "NSFileHandle+PDS.h"
#import <extobjc/EXTScope.h>

@interface PDSInternalParallelSubDownloadTask ()
@property(nonatomic, strong) NSURLSessionTask *task;
@property(nonatomic, weak) PDSSessionDelegate *delegate;
@property(nonatomic, weak) NSURLSession *session;
@property(nonatomic, strong) PDSDownloadUrlRequest *request;
@property(nonatomic, strong) PDSFileSubSection *fileSection;
@property(nonatomic, strong) NSFileHandle *fileHandle;
@end

@implementation PDSInternalParallelSubDownloadTask {
    PDSInternalParallelSubDownloadTaskProgressBlock _progressBlock;
    NSOperationQueue *_progressQueue;
}
@synthesize retryCount;

- (void)cancel {
    [self.task cancel];
}

- (void)suspend {
    [self.task suspend];
}

- (void)resume {
    [self.task resume];
}

- (void)start {
    [self resume];
}

- (id <PDSInternalTask>)restart {
    return nil;
}

#pragma mark Properties

- (NSUInteger)identifier {
    return self.task.taskIdentifier;
}

- (instancetype)initWithRequest:(PDSDownloadUrlRequest *)request downloadFileSection:(PDSFileSubSection *)downloadFileSection session:(NSURLSession *)session sessionDelegate:(PDSSessionDelegate *)sessionDelegate {
    self = [self init];
    if (self) {
        self.request = request;
        self.fileSection = downloadFileSection;
        self.session = session;
        self.delegate = sessionDelegate;
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setupFileHandle];
    [self setupDownloadTask];
}

- (void)setupFileHandle {
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.request.destination];
    [self.fileHandle pds_seekToOffset:self.fileSection.seekOffset error:NULL];
}

- (void)setupDownloadTask {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.request.downloadUrl]];
    NSString *range;
    uint64_t rangeStart = self.fileSection.offset + self.fileSection.committed;
    uint64_t rangeEnd = MIN(self.request.fileSize - 1, self.fileSection.offset + self.fileSection.size - 1);

    if (rangeEnd > rangeStart) {
        range = [NSString stringWithFormat:@"bytes=%lld-%lld", rangeStart, rangeEnd];
    } else {
        range = [NSString stringWithFormat:@"bytes=%lld-", rangeStart];
    }

    [request setValue:range forHTTPHeaderField:@"Range"];
    self.task = [self.session dataTaskWithRequest:request];
    @weakify(self);
    [self.delegate addDownloadDataReceiveHandlerForTaskWithIdentifier:self.task.taskIdentifier
                                                              session:self.session
                                                  dataReceivedHandler:^(NSData *data, NSURLSessionTask *task) {
                                                      @strongify(self);
                                                      @synchronized (self) {
                                                          [self.fileHandle pds_writeData:data error:NULL];
                                                          self.fileSection.committed += data.length;
                                                          if(self->_progressBlock) {
                                                              NSOperationQueue *toUseQueue = self->_progressQueue ?: [NSOperationQueue mainQueue];
                                                              [toUseQueue addOperationWithBlock:^{
                                                                  self->_progressBlock((int64_t) data.length, self.fileSection.committed, self.fileSection.size, self.identifier);
                                                              }];
                                                          }
                                                      }
                                                  }
                                              dataReceiveHandlerQueue:nil];
}

- (void)dealloc {
    [self.fileHandle pds_close:nil];
}

- (void)setProgressBlock:(PDSInternalParallelSubDownloadTaskProgressBlock)progressBlock {
    [self setProgressBlock:progressBlock queue:nil];
}

- (void)setProgressBlock:(PDSInternalParallelSubDownloadTaskProgressBlock)progressBlock queue:(NSOperationQueue *)queue {
    @synchronized (self) {
        self->_progressBlock = progressBlock;
        self->_progressQueue = queue;
    }
}

@end
