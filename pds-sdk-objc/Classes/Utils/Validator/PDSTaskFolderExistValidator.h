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
#import <PDS_SDK/PDSTaskValidator.h>


/**
 * 文件目录存在校验器，如果目录不存在会创建对应的目录，如果创建失败验证器会返回失败
 */
@interface PDSTaskFolderExistValidator : PDSTaskValidator

+ (instancetype)validatorWithFolderPath:(NSString *)folderPath;

@end