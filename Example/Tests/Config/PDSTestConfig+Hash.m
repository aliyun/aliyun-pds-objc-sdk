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

#import "PDSTestConfig+Hash.h"


@implementation PDSTestConfig (Hash)
- (NSString *)hashFilePath {
    return [[NSBundle mainBundle] pathForResource:@"hash" ofType:@"sample"];
}

- (NSData *)hashFileData {
    return [NSData dataWithContentsOfFile:self.hashFilePath];
}

-(NSString *)crc64HashValue {
    return @"80907e43f54fe0c2";
}

- (NSString *)crc32HashValue {
    return @"882b677d";
}

- (NSString *)sha1HashValue {
    return @"77b6e18473f37f2af555e03a4d63f6f2b111c8e1";
}

- (NSString *)md5HashValue {
    return @"13fd09d8c0a133f25a47d583db73bc97";
}

@end
