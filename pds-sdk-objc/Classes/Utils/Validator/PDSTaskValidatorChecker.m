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

#import "PDSTaskValidatorChecker.h"
#import "PDSTaskValidator.h"


@implementation PDSTaskValidatorChecker {

}
+ (BOOL)passValidators:(NSArray<PDSTaskValidator *> *)validators error:(NSError **)error {
    if(!validators.count) {
        return YES;
    }
    __block BOOL passed = YES;
    __block NSError *theError = nil;
    [validators enumerateObjectsUsingBlock:^(PDSTaskValidator *validator, NSUInteger idx, BOOL *stop) {
        passed = [validator validateWithError:&theError];
        if(!passed) {
            *stop = YES;
            return;
        }
    }];
    if(theError) {//绕过NSError *autorelease *的隐式声明导致的野指针错误
        *error = theError;
    }
    return passed;
}

@end
