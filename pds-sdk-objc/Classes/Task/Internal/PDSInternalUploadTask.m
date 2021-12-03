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

#import "PDSInternalUploadTask.h"
#import "PDSFileSubSection.h"
#import "PDSUploadFileRequest.h"
#import "PDSSessionDelegate.h"
#import "NSFileHandle+PDS.h"

@interface PDSInternalUploadTask ()
@property(nonatomic, strong) NSURLSessionUploadTask *task;
@property(nonatomic, weak) PDSSessionDelegate *delegate;
@property(nonatomic, weak) NSURLSession *session;
@property(nonatomic, strong) PDSUploadFileRequest *request;
@property(nonatomic, strong) PDSFileSubSection *uploadSection;
@property(nonatomic, strong) NSFileHandle *fileHandle;
@end


@implementation PDSInternalUploadTask {

}

@synthesize retryCount;

- (instancetype)initWithRequest:(PDSUploadFileRequest *)request uploadSection:(PDSFileSubSection *)uploadSection session:(NSURLSession *)session sessionDelegate:(PDSSessionDelegate *)sessionDelegate {
    self = [self init];
    if (self) {
        self.request = request;
        self.uploadSection = uploadSection;
        self.session = session;
        self.delegate = sessionDelegate;
    }
    return self;
}

- (void)cancel {
    @synchronized (self) {
        [self.task cancel];
    }
}

- (void)suspend {
    @synchronized (self) {
        [self.task suspend];
    }
}

- (void)resume {
    @synchronized (self) {
        if (self.task) {
            [self.task resume];
        } else {
            [self startTask];
        }
    }
}

- (void)startTask {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.uploadSection.outputUrl]];
    request.HTTPMethod = @"PUT";
    self.fileHandle = [NSFileHandle fileHandleForReadingAtPath:self.request.uploadPath];
    [self.fileHandle pds_seekToOffset:self.uploadSection.seekOffset error:NULL];
    NSData *uploadData = [self.fileHandle pds_readDataUpToLength:self.uploadSection.size error:nil];
    [self.fileHandle pds_close:nil];
    self.task = [self.session uploadTaskWithRequest:request fromData:uploadData];
    [self.task resume];
}

- (void)start {
    [self resume];
}

- (id <PDSInternalTask>)restart {
    PDSInternalUploadTask *task = [[PDSInternalUploadTask alloc] initWithRequest:self.request
                                                                   uploadSection:self.uploadSection
                                                                         session:self.session
                                                                 sessionDelegate:self.delegate];
    task.retryCount = self.retryCount + 1;
    [task resume];
    return task;
}

- (NSUInteger)identifier {
    return self.task.taskIdentifier;
}


@end