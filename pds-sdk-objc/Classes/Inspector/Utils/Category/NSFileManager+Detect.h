//
//  NSFileManager+Detect.h
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Detect)

- (uint64_t)fileSizeForPath:(NSString *)filePath;

- (NSString *)mimeTypeForPath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END

