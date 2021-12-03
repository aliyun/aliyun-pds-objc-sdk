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

#ifndef PDS_SDK_OBJC_SDAPIFILEPARINFOITEM_H
#define PDS_SDK_OBJC_SDAPIFILEPARINFOITEM_H

#import <Foundation/Foundation.h>

@interface PDSAPIUploadFilePartInfoItem : NSObject
@property(nonatomic, assign) NSInteger partNumber;
@property(nonatomic, copy) NSString *uploadUrl;
@property(nonatomic, assign) uint64_t partSize;
@property(nonatomic, copy) NSString *etag;

- (instancetype)initWithPartNumber:(NSInteger)partNumber uploadUrl:(NSString *)uploadUrl;

@end

#endif //PDS_SDK_OBJC_SDAPIFILEPARINFOITEM_H
