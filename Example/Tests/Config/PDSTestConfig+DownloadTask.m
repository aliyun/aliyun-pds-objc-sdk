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

#import "PDSTestConfig+DownloadTask.h"


@implementation PDSTestConfig (DownloadTask)

- (NSString *)normalDownloadUrl {
    return self.config[@"download_url"];
}

- (NSString *)normalDownloadFileID {
    return self.config[@"download_file_id"];
}

- (NSString *)normalDownloadHash {
    return self.config[@"download_hash"];
}

- (uint64_t)normalDownloadSize {
    return [self.config[@"download_size"] unsignedLongLongValue];
}

- (NSString *)normalDownloadFileName {
    return self.config[@"download_file_name"];
}

- (NSString *)livepDownloadUrl {
    return self.config[@"livep_download_url"];
}

- (NSString *)livepDownloadFileID {
    return self.config[@"livep_download_file_id"];
}

- (NSString *)livepDownloadHash {
    return self.config[@"livep_download_hash"];
}

- (uint64_t)livepDownloadSize {
    return [self.config[@"livep_download_size"] unsignedLongLongValue];
}

- (NSString *)livepDownloadFileName {
    return self.config[@"livep_download_file_name"];
}


- (NSString *)downloadDestination {
    NSURL *documentUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *downloadDirPath = [documentUrl URLByAppendingPathComponent:@"downloaded"];
    [self createDirAtPath:downloadDirPath.path];
    return downloadDirPath.path;
}

- (void)cleanDownloaded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:self.downloadDestination]) {
        [fileManager removeItemAtPath:self.downloadDestination error:nil];
    }
}
@end