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

#import "PDSProgressData.h"


@implementation PDSProgressData {

}

- (instancetype)initWithCommitted:(uint64_t)committed totalCommitted:(uint64_t)totalCommitted expectedToCommit:(uint64_t)expectedToCommit {
    self = [super init];
    if (self) {
        _committed = committed;
        _totalCommitted = totalCommitted;
        _expectedToCommit = expectedToCommit;
    }

    return self;
}

@end