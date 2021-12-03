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

#import "PDSTaskDiskCapacityValidator.h"
#import "NSFileManager+PDS.h"


@interface PDSTaskDiskCapacityValidator ()
@property(nonatomic, assign) uint64_t size;
@end

@implementation PDSTaskDiskCapacityValidator {

}
- (BOOL)validateWithError:(NSError **)error {
    uint64_t availableCapacity = [[NSFileManager defaultManager] pds_diskAvailableCapacity];
    if (availableCapacity == 0) {
        return YES;
    }
    return (availableCapacity - self.size) > 1000;
}

- (id)initWithSize:(uint64_t)size {
    self = [self init];
    self.size = size;
    return self;
}

+ (instancetype)validatorWithSize:(uint64_t)size {
    PDSTaskDiskCapacityValidator *validator = [[PDSTaskDiskCapacityValidator alloc] initWithSize:size];
    return validator;
}


@end