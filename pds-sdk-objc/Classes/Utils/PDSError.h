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

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const PDSErrorDomain;

typedef NS_ERROR_ENUM(PDSErrorDomain,PDSError)
{
    //公用
    PDSErrorUnknown = -1,//未知错误
    PDSErrorCancelled = -999,//用户取消
    //媒体文件
    PDSErrorAssetIdentifierNotAvailable = -1000,//用于从iOS相册库中导出照片的localIdentifier无效
    //文件错误
    PDSErrorFileCreatedFailed = -2000,//本地创建文件/文件夹失败,检查权限/磁盘空间
    PDSErrorFileNotExist = -2001,//本地文件不存在
    PDSErrorFileNameConflict = -2002,//文件名已经存在，重命名失败
    //Hash错误
    PDSErrorFileHashCalculateFailed = -3000,//文件的Hash计算失败
    PDSErrorFileHashNotEqual = -3001,//文件的Hash不匹配
};


FOUNDATION_EXPORT NSString *const PDSErrorCodeCommonFormatInvalid;//返回内容格式错误，没有返回预期的数据，SDK无法解析
FOUNDATION_EXPORT NSString *const PDSErrorCodeCommonFormatInvalidMessage;

FOUNDATION_EXPORT NSString *const PDSErrorCodeCommonUnknown;//服务端返回接口报错，不清楚发生了什么事情
FOUNDATION_EXPORT NSString *const PDSErrorCodeCommonUnknownMessage;

FOUNDATION_EXPORT NSString *const PDSErrorCodeCreateFilePreHashMatched;//预Hash请求匹配,继续计算全量Hash

NS_ASSUME_NONNULL_END
