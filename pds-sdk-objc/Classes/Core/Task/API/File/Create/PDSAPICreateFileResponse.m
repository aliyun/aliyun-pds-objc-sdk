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

#import "PDSAPICreateFileResponse.h"
#import "PDSMacro.h"
#import "PDSAPIUploadFilePartInfoItem.h"
#import "PDSRequestError.h"

@interface PDSAPICreateFileResponse ()

@end

@implementation PDSAPICreateFileResponse {

}

+ (id)deserialize:(NSDictionary<NSString *, id> *)dict {
    PDSAPICreateFileResponse *response = [[PDSAPICreateFileResponse alloc] initWithData:dict];
    return response;
}

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        NSNumber *rapid_upload = data[@"rapid_upload"];
        NSString *status = data[@"status"];
        NSString *type = data[@"type"];
        /// 判断文件是否可秒传 status = available 或者 rapid_upload = true 都是秒传
        if ((rapid_upload && [rapid_upload boolValue]) || [@"available" isEqualToString:status] || [type isEqualToString:@"folder"]) {
            //预秒传成功，这种情况下直接返回成功结果就行了
            self.fileId = data[@"file_id"];
            self.revisionId = data[@"revision_id"];
            self.completeTime = [[NSDate date] timeIntervalSince1970] * 1000;
            self.fileName = data[@"file_name"];
            self.status = PDSAPICreateFileStatusFinished;
        } else {//需要准备上传
            self.uploadId = data[@"upload_id"];
            self.fileId = data[@"file_id"];
            self.revisionId = data[@"revision_id"];
            NSArray *partInfoDataList = data[@"part_info_list"];
            NSMutableArray *parInfoList = nil;
            if (!PDSIsEmpty(partInfoDataList)) {
                parInfoList = [[NSMutableArray alloc] initWithCapacity:partInfoDataList.count];
                [partInfoDataList enumerateObjectsUsingBlock:^(NSDictionary *partInfo, NSUInteger idx, BOOL *stop) {
                    NSNumber *partNumber = partInfo[@"part_number"];
                    NSString *uploadUrl = partInfo[@"upload_url"];
                    [parInfoList addObject:[[PDSAPIUploadFilePartInfoItem alloc] initWithPartNumber:partNumber.integerValue
                                                                                    uploadUrl:uploadUrl]];
                }];
                self.partInfoList = parInfoList;
                self.status = PDSAPICreateFileStatusWaiting;
            } else {//没有返回分片信息，直接报错
                self.error = [PDSRequestError invalidResponseError];
                self.status = PDSAPICreateFileStatusFinished;
            }
        }
    }
    return self;
}

@end
