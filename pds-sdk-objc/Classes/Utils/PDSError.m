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

#import "PDSError.h"

NSErrorDomain const PDSErrorDomain = @"PDSErrorDomain";

NSString *const PDSErrorCodeCommonFormatInvalid = @"ResultFormatInvalid";//返回内容格式错误，没有返回预期的数据，SDK无法解析
NSString *const PDSErrorCodeCommonFormatInvalidMessage = @"Result can't be recognized.JSON format failed, or result data can't be parsed";

NSString *const PDSErrorCodeCommonUnknown = @"ServerResponseErrorUnknown";
NSString *const PDSErrorCodeCommonUnknownMessage = @"Server Response code is error,unfortunately client doesn't known what happened";


NSString *const PDSErrorCodeCreateFilePreHashMatched = @"PreHashMatched";//预Hash请求匹配,继续计算全量Hash

