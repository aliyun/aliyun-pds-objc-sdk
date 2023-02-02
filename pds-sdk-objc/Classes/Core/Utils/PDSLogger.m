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

#import "PDSLogger.h"

@implementation PDSLogger {

}
- (void)log:(NSString *)message level:(PDSLoggerLevel)level {
    if(level & self.recordLogLevel) {
        NSLog(@"PDSLogger: %@",message);
    }
}

+ (void)logError:(NSString *)message {
    [[self sharedInstance] log:message level:PDSLoggerLevelError];
}

+ (void)logWarning:(NSString *)message {
    [[self sharedInstance] log:message level:PDSLoggerLevelWarning];
}

+ (void)logDebug:(NSString *)message {
    [[self sharedInstance] log:message level:PDSLoggerLevelDebug];
}

+ (void)setRecordLogLevel:(PDSLoggerLevel)recordLogLevel {
    [self sharedInstance].recordLogLevel = recordLogLevel;
}


+ (PDSLogger *)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.recordLogLevel = PDSLoggerLevelError | PDSLoggerLevelWarning;
}


@end
