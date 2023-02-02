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


@interface PDSTaskDiskCapacityValidator : PDSTaskValidator
/**
 * 创建磁盘剩余容量检测的验证器
 * @param size 期望磁盘空间剩余的容量,单位为byte
 * @return 验证器
 */
+ (instancetype)validatorWithSize:(uint64_t)size;

@end