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

#import "PDSDownloadUrlRequest.h"


@implementation PDSDownloadUrlRequest {

}
- (instancetype)initWithDownloadUrl:(NSString *)downloadUrl destination:(NSString *)destination userID:(NSString *)userID parentID:(NSString *)parentID fileSize:(uint64_t)fileSize fileID:(NSString *)fileID hashValue:(NSString *)hashValue hashType:(PDSFileHashType)hashType driveID:(NSString *)driveID shareID:(NSString *)shareID {
    self = [super init];
    if (self) {
        _downloadUrl = [downloadUrl copy];
        _userID = [userID copy];
        _parentID = [parentID copy];
        _fileSize = fileSize;
        _fileID = [fileID copy];
        _hashValue = [hashValue copy];
        _hashType = hashType;
        _destination = [destination copy];
        _shareID = shareID;
        _driveID = driveID;
    }

    return self;
}

@end
