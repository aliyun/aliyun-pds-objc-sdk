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

@interface PDSCompletionData : NSObject

@property(nonatomic, readonly, nullable) NSData *responseBody;

@property(nonatomic, readonly, nullable) NSURLResponse *responseMetadata;

@property(nonatomic, readonly, nullable) NSError *responseError;

@property(nonatomic, readonly, nullable) NSURL *urlOutput;


- (instancetype)initWithCompletionData:(nullable NSData *)responseBody
                      responseMetadata:(nullable NSURLResponse *)responseMetadata
                         responseError:(nullable NSError *)responseError
                             urlOutput:(nullable NSURL *)urlOutput;

@end

NS_ASSUME_NONNULL_END
