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

// https://github.com/Specta/Specta


@import PDS_SDK;
#import "PDSTestConfig.h"

SpecBegin(UploadFileTask)
__block PDSUploadTask *uploadTask;
__block PDSTestConfig *testConfig;
    beforeAll(^{
        testConfig = [PDSTestConfig new];
        [testConfig refreshSample];
    });
describe(@"001 test config", ^{
    it(@"001 sample file init", ^{
        expect(testConfig.samplePath).notTo.beNil();
        expect(testConfig.sampleSize).notTo.equal(@(0));
    });
});

describe(@"002 UploadFileTask", ^{
    it(@"001 file request init", ^{
        PDSUploadFileRequest *uploadFileRequest = [[PDSUploadFileRequest alloc] initWithUploadPath:testConfig.samplePath parentFileID:testConfig.parentID driveID:testConfig.driveID shareID:nil fileName:nil];
        expect(uploadFileRequest.fileName).equal(testConfig.sampleName);
        expect(uploadFileRequest.fileSize).equal(testConfig.sampleSize);
        expect(uploadFileRequest.contentType).toNot.beNil();
        expect(uploadFileRequest.uploadPath).equal(testConfig.samplePath);
    });
    it(@"002 normal file upload", ^{
        PDSUploadFileRequest *uploadFileRequest = [[PDSUploadFileRequest alloc] initWithUploadPath:testConfig.samplePath parentFileID:testConfig.parentID driveID:testConfig.driveID shareID:nil fileName:nil];
        uploadTask = [[PDSClientManager defaultClient].file uploadFile:uploadFileRequest taskIdentifier:nil];
        expect(uploadTask).toNot.beNil();
        waitUntilTimeout(100.0, ^(DoneCallback done) {
            [uploadTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, NSString *taskIdentifier) {
                expect(requestError).to.beNil();
                expect(result).notTo.beNil();
                expect(result.fileName).notTo.beNil();
                expect(result.fileID).notTo.beNil();
                expect(result.uploadID).notTo.beNil();
                expect(result.driveID).notTo.beNil();
                done();
            }];
        });
    });
    it(@"003 resume file upload",^{
        [testConfig refreshSample];
        PDSUploadFileRequest *uploadFileRequest = [[PDSUploadFileRequest alloc] initWithUploadPath:testConfig.samplePath parentFileID:testConfig.parentID driveID:testConfig.driveID shareID:nil fileName:nil];
        uploadTask = [[PDSClientManager defaultClient].file uploadFile:uploadFileRequest taskIdentifier:nil];
        expect(uploadTask).toNot.beNil();
        //暂停0.1秒再暂停上传任务，确保上传任务已经进入了上传流程
        waitUntilTimeout(1000, ^(DoneCallback done) {
            NSTimeInterval delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [uploadTask suspend];
                //重新创建一个上传任务，使用之前的taskID和配置参数
                uploadTask = [[PDSClientManager defaultClient].file uploadFile:uploadFileRequest taskIdentifier:uploadTask.taskIdentifier];
                [uploadTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, NSString *taskIdentifier) {
                    expect(requestError).to.beNil();
                    done();
                }];
                 
            });
        });
});
//    it(@"004 zero size file upload", ^{
//        PDSUploadFileRequest *uploadFileRequest = [[PDSUploadFileRequest alloc] initWithUploadPath:testConfig.samplePath parentFileID:testConfig.parentID driveID:testConfig.driveID shareID:nil fileName:nil];
//    });
});

SpecEnd
