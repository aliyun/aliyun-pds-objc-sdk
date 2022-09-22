// /*
// * Copyright 2009-2022 Alibaba Cloud All rights reserved.
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
#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIGetShareTokenRequest : PDSAPIRequest
//分享ID
@property(nonatomic, copy) NSString *shareId;
//分享密码
@property(nonatomic, copy) NSString *sharePassword;
//管理员是否也要检查密码
@property(nonatomic, assign) BOOL checkSharePassword;

- (instancetype)initWithShareId:(NSString *)shareId sharePassword:(NSString *)sharePassword
             checkSharePassword:(BOOL)checkSharePassword;

@end

NS_ASSUME_NONNULL_END