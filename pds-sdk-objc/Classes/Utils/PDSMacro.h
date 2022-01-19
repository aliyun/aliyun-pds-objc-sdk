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

static inline BOOL PDSIsEmpty(id thing) {
    return thing == nil
            || ([thing respondsToSelector:@selector(length)]
            && [(NSData *) thing length] == 0)
            || ([thing respondsToSelector:@selector(count)]
            && [(NSArray *) thing count] == 0);
};


static inline NSString *PDSSDKStorageFolderPath() {
    static dispatch_once_t predicate = 0;
    static NSString *storageFolderPath = nil;
    dispatch_once(&predicate, ^{
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        storageFolderPath = [documentPath stringByAppendingPathComponent:@"PDSSDK"];
    });
    return storageFolderPath;
};

