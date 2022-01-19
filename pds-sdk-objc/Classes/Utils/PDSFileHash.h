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

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

#import <Photos/Photos.h>

#endif

typedef NS_ENUM(NSInteger, PDSFileHashType) {
    PDSFileHashTypeNone,
    PDSFileHashTypeMD5,
    PDSFileHashTypeSha1,
    PDSFileHashTypeSha512,
    PDSFileHashTypeCrc32,
    PDSFileHashTypeCrc64,
};

@interface PDSFileHash : NSObject
+ (NSString *)hashOfData:(NSData *)data hashType:(PDSFileHashType)hashType;

+ (NSString *)md5HashOfData:(NSData *)data;

+ (NSString *)sha1HashOfData:(NSData *)data;

+ (NSString *)sha512HashOfData:(NSData *)data;

+ (NSString *)crc32HashOfData:(NSData *)data;

+ (NSString *)crc64HashOfData:(NSData *)data;

+ (NSString *)hashOfFileAtPath:(NSString *)filePath hashType:(PDSFileHashType)hashType;

+ (NSString *)md5HashOfFileAtPath:(NSString *)filePath;

+ (NSString *)sha1HashOfFileAtPath:(NSString *)filePath;

+ (NSString *)sha512HashOfFileAtPath:(NSString *)filePath;

+ (NSString *)crc32HashOfFileAtPath:(NSString *)filePath;

+ (NSString *)crc64HashOfFileAtPath:(NSString *)filePath;

@end
