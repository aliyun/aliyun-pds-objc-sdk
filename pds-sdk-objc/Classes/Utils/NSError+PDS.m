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

#import "NSError+PDS.h"
#import <PDS_SDK/PDSError.h>
#import <PDS_SDK/PDSMacro.h>


@implementation NSError (PDS)

+ (NSError *)pds_errorWithCode:(PDSError)errorCode {

    return [self pds_errorWithCode:errorCode message:[self pds_errorMessageWithCode:errorCode]];
}

+ (NSError *)pds_errorWithCode:(PDSError)errorCode message:(NSString *)message {
    NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: PDSIsEmpty(message) ? @"" : message
    };
    return [NSError errorWithDomain:PDSErrorDomain
                               code:errorCode
                           userInfo:userInfo];
}

+ (NSString *)pds_errorMessageWithCode:(PDSError)errorCode {
    switch (errorCode) {
            //TODO 补全错误信息
        case PDSErrorFileNameConflict:
            break;
        case PDSErrorUnknown:
            break;
        case PDSErrorCancelled:
            break;
        case PDSErrorAssetIdentifierNotAvailable:
            break;
        case PDSErrorFileCreatedFailed:
            break;
        case PDSErrorFileNotExist:
            break;
        case PDSErrorFileHashCalculateFailed:
            break;
        case PDSErrorFileHashNotEqual:
            break;
    }
    return nil;
}
@end
