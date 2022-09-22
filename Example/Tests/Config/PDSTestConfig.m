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

#import "PDSTestConfig.h"
#import <PDS_SDK/NSFileManager+PDS.h>
#import <PDS_SDK/PDSClientConfig.h>
#import <PDS_SDK/PDSClientManager.h>

@interface PDSTestConfig ()
@property(nonatomic, copy) NSString *samplePath;
@property(nonatomic, copy) NSString *sampleName;
@end

@implementation PDSTestConfig {

}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    [self setupConfig];
}

- (void)setupConfig {
    NSData *configData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"config" withExtension:@"json"]];
    self.config = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingFragmentsAllowed error:nil];
    PDSClientConfig *clientConfig = [[PDSClientConfig alloc] init];
    clientConfig.host = self.config[@"host"];
    clientConfig.userAgent = self.config[@"user_agent"];
    [PDSClientManager setupWithAccessToken:self.config[@"access_token"] clientConfig:clientConfig];
}

- (void)refreshSample {
    NSURL *documentUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *samplesDirPath = [documentUrl URLByAppendingPathComponent:@"samples"];
    self.sampleName = [NSString stringWithFormat:@"%@.bin",[NSUUID UUID].UUIDString];
    [self createDirAtPath:samplesDirPath.path];

    self.samplePath = [samplesDirPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",self.sampleName]].path;
    NSData *sampleData = [self randomDataOfSize:(1024*10000)];
    [sampleData writeToFile:self.samplePath atomically:NO];
}

- (uint64_t)sampleSize {
    return [[NSFileManager defaultManager] pds_fileSizeForPath:[self samplePath]];
}

- (NSString *)userID {
    return self.config[@"user_id"];
}

- (NSString *)parentID {
    return self.config[@"parent_file_id"];
}

- (NSString *)toMoveParentID {
    return self.config[@"to_parent_file_id"];
}

- (NSString *)driveID {
    return self.config[@"drive_id"];
}

- (NSString *)driveName {
    return self.config[@"drive_name"];
}

- (NSString *)owner {
    return self.config[@"owner"];
}


- (nullable NSData *)randomDataOfSize:(size_t)sizeInBytes
{
    void *buff = malloc(sizeInBytes);
    if (buff == NULL) {
        return nil;
    }
    arc4random_buf(buff, sizeInBytes);

    return [NSData dataWithBytesNoCopy:buff length:sizeInBytes freeWhenDone:YES];
}

- (void)createDirAtPath:(NSString *)dirPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dirPath]) {
        [fileManager createDirectoryAtPath:dirPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
}

- (void)dealloc {
    [[NSFileManager defaultManager] removeItemAtPath:self.samplePath error:nil];
}
@end
