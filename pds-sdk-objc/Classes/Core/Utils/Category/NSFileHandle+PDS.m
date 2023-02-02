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

#import "NSFileHandle+PDS.h"
#import "NSError+PDS.h"


@implementation NSFileHandle (PDS)

- (NSData *)pds_readDataUpToLength:(NSUInteger)length error:(NSError **)error {
    if (@available(iOS 13.0, *)) {
        return [self readDataUpToLength:length error:error];
    } else {
        NSData *data = nil;
        @try {
            data = [self readDataOfLength:length];
        }
        @catch (NSException *e) {
            if (error != NULL) {
                *error = [NSError pds_errorWithCode:PDSErrorFileReadError];
            }
            return nil;
        }
        return data;
    }
}

- (BOOL)pds_writeData:(NSData *)data error:(NSError **)error {
    if (@available(iOS 13.0, *)) {
        return [self writeData:data error:error];
    } else {
        @try {
            [self writeData:data];
        }
        @catch (NSException *e) {
            if (error != NULL) {
                *error = [NSError pds_errorWithCode:PDSErrorFileReadError];
            }
            return NO;
        }
        return YES;
    }
}

- (BOOL)pds_close:(NSError **)error {
    if (@available(iOS 13.0, *)) {
        return [self closeAndReturnError:error];
    } else {
        @try {
            [self closeFile];
        }
        @catch (NSException *e) {
            if (error != NULL) {
                NSDictionary *userInfo = @{
                        NSLocalizedDescriptionKey: @"Failed to close file",
                };
                *error = [NSError errorWithDomain:@"MyStuff" code:123 userInfo:userInfo];
            }
            return NO;
        }
        return YES;
    }
}

- (BOOL)pds_seekToOffset:(uint64_t)offset error:(NSError **)Error {
    if (@available(iOS 13.0, *)) {
        return [self seekToOffset:offset error:Error];
    } else {
        @try {
            [self seekToFileOffset:offset];
        }
        @catch (NSException *e) {
            if (Error != NULL) {
                NSDictionary *userInfo = @{
                        NSLocalizedDescriptionKey: @"Failed to close file",
                };
                *Error = [NSError errorWithDomain:@"MyStuff" code:123 userInfo:userInfo];
            }
            return NO;
        }
        return YES;
    }
}

@end
