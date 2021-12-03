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

#import "PDSInternalHashTask.h"
#import "PDSFileHash.h"
#import "PDSError.h"
#import "PDSMacro.h"
#import "NSError+PDS.h"
#import "NSFileHandle+PDS.h"
#import <extobjc/EXTScope.h>

@interface PDSInternalHashTask ()

/// 要计算的hash文件路径
@property(nonatomic, copy) NSString *filePath;
/// 要计算的hash类型
@property(nonatomic, assign) PDSFileHashType hashType;
/// 任务是否已经被取消
@property(nonatomic, assign) BOOL cancelled;
/// 任务是否完成
@property(nonatomic, assign) BOOL finished;
/// 计算hash的队列
@property(nonatomic, strong) dispatch_queue_t hashOperationQueue;
/// 计算出得hash值
@property(nonatomic, copy) NSString *calculatedHashValue;
/// 是否计算完成
@property(nonatomic, assign) BOOL success;
/// 计算过程中发生的错误
@property(nonatomic, strong) NSError *error;
/// hash计算方式
@property(nonatomic, assign) PDSFileHashCalculateType calculateType;
@end

@implementation PDSInternalHashTask {
    PDSInternalHashTaskResponseBlock _responseBlock;
    NSOperationQueue *_responseBlockQueue;
}

@synthesize retryCount;

- (instancetype)initWithFilePath:(NSString *)filePath hashType:(PDSFileHashType)hashType hashValue:(NSString *)hashValue calculateType:(PDSFileHashCalculateType)calculateType {
    self = [self init];
    if (self) {
        _filePath = [filePath copy];
        _hashType = hashType;
        _hashValue = hashValue;
        _calculateType = calculateType;
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath hashType:(PDSFileHashType)hashType hashValue:(NSString *)hashValue {
    return [self initWithFilePath:filePath hashType:hashType hashValue:hashValue calculateType:PDSFileHashCalculateTypeFull];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_queue_attr_t qosAttribute =
                dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
        self.hashOperationQueue =
                dispatch_queue_create("com.aliyun.pds.PDSInternalHashTask.queue", qosAttribute);
    }
    return self;
}

- (void)cancel {
    @synchronized (self) {
        if (!self.finished) {
            self.cancelled = YES;
        }
    }
}

- (void)suspend {
    //hash任务只支持取消，不支持暂停
    [self cancelled];
}

- (void)resume {
    @synchronized (self) {
        if (!self.finished || !self.cancelled) {
            [self _start];
        }
    }
}

- (void)start {
    [self resume];
}

- (id <PDSInternalTask>)restart {
    return nil;
}

- (void)_start {
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath];
    if (!fileExist) {
        @synchronized (self) {
            self.finished = YES;
            self.error = [NSError pds_errorWithCode:PDSErrorFileNotExist];
        }
        [self callResponseBlockIfNeeded];
        return;
    }

    @weakify(self);
    dispatch_async(self.hashOperationQueue, ^{
        @strongify(self);
        NSString *fileHash = nil;
        if (self.calculateType == PDSFileHashCalculateTypeFull) {//全量hash
            fileHash = [PDSFileHash hashOfFileAtPath:self.filePath hashType:self.hashType];
        } else {//只算1K
            NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self.filePath];
            NSError *readError = nil;
            NSData *fileData = [handle pds_readDataUpToLength:1024 error:&readError];
            if (readError || !fileData) {
                @synchronized (self) {
                    self.error = [NSError pds_errorWithCode:PDSErrorFileHashCalculateFailed];
                    self.finished = YES;
                    [self callResponseBlockIfNeeded];
                }
                return;
            }
            fileHash = [PDSFileHash hashOfData:fileData hashType:self.hashType];
        }
        @synchronized (self) {
            BOOL success = NO;
            if (PDSIsEmpty(fileHash)) {//计算被取消了
                self.success = success;
                return;
            } else {
                if (PDSIsEmpty(self.hashValue)) {//没有传入Hash值，不进行比较，直接返回
                    success = YES;
                } else {
                    success = [[self.hashValue lowercaseString] isEqualToString:fileHash];
                    if (!success) {
                        self.error = [NSError pds_errorWithCode:PDSErrorFileHashNotEqual];
                    }
                }
                self.finished = YES;
                self.success = success;
                self.calculatedHashValue = fileHash;
            }
        }
        [self callResponseBlockIfNeeded];
    });
}

- (void)setResponseBlock:(PDSInternalHashTaskResponseBlock)responseBlock {
    [self setResponseBlock:responseBlock queue:nil];
}

- (void)setResponseBlock:(PDSInternalHashTaskResponseBlock)responseBlock queue:(NSOperationQueue *)queue {
    @synchronized (self) {
        self->_responseBlock = responseBlock;
        self->_responseBlockQueue = queue;
        [self callResponseBlockIfNeeded];
    }
}

- (void)callResponseBlockIfNeeded {
    __block PDSInternalHashTaskResponseBlock responseBlock = nil;
    __block NSOperationQueue *queue = nil;
    NSError *error = nil;
    __block NSString *calculatedHashValue = nil;
    __block BOOL finished = NO;
    __block BOOL success = NO;
    __block BOOL cancelled = NO;
    @synchronized (self) {
        responseBlock = self->_responseBlock;
        queue = self->_responseBlockQueue ?: [NSOperationQueue mainQueue];
        error = self.error;
        finished = self.finished;
        calculatedHashValue = self.calculatedHashValue;
        success = self.success;
        cancelled = self.cancelled;
    }
    if (finished && responseBlock && !cancelled) {
        [queue addOperationWithBlock:^{
            responseBlock(success, calculatedHashValue, error);
        }];
    }
}

@end
