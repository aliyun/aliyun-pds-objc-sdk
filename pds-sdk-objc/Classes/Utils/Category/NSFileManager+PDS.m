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

#import "NSFileManager+PDS.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PDSMacro.h"


@implementation NSFileManager (PDS)
- (uint64_t)pds_fileSizeForPath:(NSString *)filePath {
    if (![self fileExistsAtPath:filePath]) {
        return 0;
    }
    uint64_t fileSize = [[self attributesOfItemAtPath:filePath error:nil] fileSize];
    return fileSize;
}

- (NSString *)pds_mimeTypeForPath:(NSString *)filePath {
    if ([self fileExistsAtPath:filePath]) {
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge_retained CFStringRef) [filePath pathExtension], NULL);
        if (UTI != NULL) {
            CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
            CFRelease(UTI);
            if (MIMEType == NULL) {
                return @"application/octet-stream";
            }
            return (__bridge_transfer NSString *) (MIMEType);
        }
    }
    return nil;
}


- (uint64_t)pds_diskAvailableCapacity {
    uint64_t availableCapacity = 0;
    if (@available(iOS 11.0, *)) {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:NSTemporaryDirectory()];
        NSDictionary *results = [fileURL resourceValuesForKeys:@[NSURLVolumeAvailableCapacityForImportantUsageKey] error:nil];
        NSNumber *availableCapacityNum = results[NSURLVolumeAvailableCapacityForImportantUsageKey];
//        这里拿到的值的单位是bytes，iOS11是这样算的1000MB = 1，1000进制算的
//        bytes->KB->MB->G
        availableCapacity = availableCapacityNum.unsignedLongLongValue;
    } else {
        /// 剩余大小
        uint64_t freeSize = 0;
        /// 是否登录
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
        if (dictionary) {
            NSNumber *_free = dictionary[NSFileSystemFreeSize];
            freeSize = [_free unsignedLongLongValue];
        }
        availableCapacity = freeSize;
    }
    return availableCapacity;
}

- (BOOL)pds_autoRenameFile:(NSString **)filePath {
    NSString *thePath = *filePath;
    if (!thePath) {
        return YES;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:thePath]) {
        return YES;
    }
    NSInteger tryCount = 0;
    BOOL success = NO;
    NSString *fileDir = [thePath stringByDeletingLastPathComponent];
    NSString *fileName = [[thePath lastPathComponent] stringByDeletingPathExtension];
    NSString *fileExtension = [[thePath lastPathComponent] pathExtension];
    if(PDSIsEmpty(fileDir) || PDSIsEmpty(fileName)) {
        return NO;
    }
    BOOL fileExtensionExist = !PDSIsEmpty(fileExtension);
    while ((tryCount < 100) && success == NO) {//超过100次重试那么不再继续重命名
        NSMutableString *resultPath = [[fileDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ (%ld)",fileName,tryCount + 1]] mutableCopy];
        if(fileExtensionExist) {
            [resultPath appendFormat:@".%@",fileExtension];
        }
        if(![fileManager fileExistsAtPath:resultPath]) {
            *filePath = [resultPath copy];
            success = YES;
        }
        tryCount++;
    }
    return success;
}

- (BOOL)pds_removeItemAtPath:(NSString *)filePath {
    if (!filePath) {
        return YES;
    }

    if ([self fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL success = [self removeItemAtPath:filePath error:&error];
        return success;
    }
    return YES;
}
@end
