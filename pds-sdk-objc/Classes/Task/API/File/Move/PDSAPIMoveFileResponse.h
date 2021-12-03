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

#import <PDS_SDK/PDSAPIResponse.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIMoveFileResponse : PDSAPIResponse
//异步任务ID，可以通过异步任务查询接口查询本次操作是否完成
@property(nonatomic, copy) NSString *asyncTaskID;
//DomainID
@property(nonatomic, copy) NSString *domainID;
//磁盘ID
@property(nonatomic, copy) NSString *driveID;
//文件ID
@property(nonatomic, copy) NSString *fileID;
@end

NS_ASSUME_NONNULL_END
