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

#import "PDSUploadFileRequest.h"
#import "NSFileManager+PDS.h"
#import "PDSMacro.h"


@implementation PDSUploadFileRequest {

}
- (instancetype)initWithUploadPath:(NSString *)uploadPath parentFileID:(NSString *)parentFileID driveID:(NSString *_Nullable)driveID shareID:(NSString *_Nullable)shareID fileName:(NSString *_Nullable)fileName {
    self = [super init];
    if (self) {
        _uploadPath = [uploadPath copy];
        _parentFileID = [parentFileID copy];
        _driveID = [driveID copy];
        _shareID = [shareID copy];
        _sectionSize = 4 * 1000 * 1000;
        _fileSize = [[NSFileManager defaultManager] pds_fileSizeForPath:uploadPath];
        _contentType = [[NSFileManager defaultManager] pds_mimeTypeForPath:uploadPath];
        if (PDSIsEmpty(fileName)) {
            _fileName = [uploadPath lastPathComponent];
        } else {
            _fileName = fileName;
        }
    }
    return self;
}

- (NSString *)relativeUploadPath {
    if (PDSIsEmpty(self.uploadPath)) {
        return nil;
    }
    return [self.uploadPath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""];
}

@end
