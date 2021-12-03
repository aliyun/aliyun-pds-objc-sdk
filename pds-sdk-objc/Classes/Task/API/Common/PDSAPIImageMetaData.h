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

@interface PDSAPIImageMetaData : NSObject
@property(nonatomic, copy) NSString *addressLine;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *country;
@property(nonatomic, copy) NSString *district;
@property(nonatomic, copy) NSString *duration;
@property(nonatomic, copy) NSString *faces;
@property(nonatomic, copy) NSString *location;
@property(nonatomic, copy) NSString *province;
@property(nonatomic, copy) NSString *time;
@property(nonatomic, copy) NSString *township;
@property(nonatomic, assign) uint64_t height;
@property(nonatomic, assign) uint64_t width;
@end

NS_ASSUME_NONNULL_END