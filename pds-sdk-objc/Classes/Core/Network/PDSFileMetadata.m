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

#import "PDSFileMetadata.h"


@implementation PDSFileMetadata {

}
- (instancetype)initWithFileID:(NSString *)fileID revisionID:(NSString *)revisionID fileName:(NSString *)fileName
                      filePath:(NSString * _Nullable)filePath driveID:(NSString *)driveID uploadID:(NSString * _Nullable)uploadID {
    self = [super init];
    if (self) {
        self.fileID = fileID;
        self.revisionID = revisionID;
        self.fileName = fileName;
        self.filePath = filePath;
        self.driveID = driveID;
        self.uploadID = uploadID;
    }

    return self;
}

@end
