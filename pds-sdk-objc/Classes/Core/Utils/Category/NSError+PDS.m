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
        case PDSErrorFileNameConflict:
            return @"超过自动重命名尝试次数，同名文件已存在";
        case PDSErrorUnknown:
            return @"未知错误";
        case PDSErrorCancelled:
            return @"用户取消";
        case PDSErrorExportPhotoAssetFailed:
            return @"导出相册资源失败";
        case PDSErrorExportUnsupportedFormat:
            return @"相册资源的格式目前不支持导出";
        case PDSErrorFileCreatedFailed:
            return @"本地创建文件失败";
        case PDSErrorFileNotExist:
            return @"文件不存在";
        case PDSErrorFileHashCalculateFailed:
            return @"无法校验hash";
        case PDSErrorFileHashNotEqual:
            return @"hash校验不符";
        default:
            break;
    }
    return nil;
}
@end
