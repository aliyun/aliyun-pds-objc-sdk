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
#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIUpdateFileRequest : PDSAPIRequest
@property(nonatomic, copy) NSString *fileID;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, copy) NSString *driveID;
@property(nonatomic, assign) BOOL hidden;
@property(nonatomic, copy) NSString *encryptMode;
@property(nonatomic, assign) BOOL starred;
@property(nonatomic, copy) NSString *customIndexKey;
@property(nonatomic, copy) NSArray<NSString *> *labels;
@property(nonatomic, copy) NSString *userMeta;

- (instancetype)initWithFileID:(NSString *)fileID driveID:(NSString *)driveID name:(NSString *_Nullable)name desc:(NSString *_Nullable)desc hidden:(BOOL)hidden encryptMode:(NSString *_Nullable)encryptMode starred:(BOOL)starred customIndexKey:(NSString *_Nullable)customIndexKey labels:(NSArray<NSString *> *_Nullable)labels userMeta:(NSString *_Nullable)userMeta;


@end

NS_ASSUME_NONNULL_END
