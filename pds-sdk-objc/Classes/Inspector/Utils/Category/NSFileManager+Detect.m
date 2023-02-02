//
//  NSFileManager+Detect.m
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/12/7.
//

#import "NSFileManager+Detect.h"
#import <MobileCoreServices/MobileCoreServices.h>


@implementation NSFileManager (Detect)

- (uint64_t)fileSizeForPath:(NSString *)filePath {
    if (![self fileExistsAtPath:filePath]) {
        return 0;
    }
    uint64_t fileSize = [[self attributesOfItemAtPath:filePath error:nil] fileSize];
    return fileSize;
}

- (NSString *)mimeTypeForPath:(NSString *)filePath {
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

@end
