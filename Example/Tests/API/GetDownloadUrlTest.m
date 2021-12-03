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
@import PDS_SDK;
#import "PDSTestConfig.h"

SpecBegin(GetDownloadUrlAPI)

__block PDSTestConfig *testConfig;
__block PDSAPIGetDownloadUrlRequest *request;
__block PDSAPIRequestTask<PDSAPIGetDownloadUrlResponse *> *apiTask;
beforeAll(^{
    testConfig = [PDSTestConfig new];
});

describe(@"get download url", ^{
    it(@"001 create request", ^{
        request = [[PDSAPIGetDownloadUrlRequest alloc] initWithShareID:nil
                                                               driveID:testConfig.driveID
                                                                fileID:testConfig.downloadFileID
                                                              fileName:testConfig.downloadFileName];
        expect(request).toNot.beNil();
        expect(request.driveID).equal(testConfig.driveID);
        expect(request.driveID).toNot.beNil();
        expect(request.fileID).equal(testConfig.downloadFileID);
        expect(request.fileID).toNot.beNil();
        expect(request.fileName).equal(testConfig.downloadFileName);
        expect(request.fileName).toNot.beNil();
    });
    it(@"get response", ^{
       apiTask = [[PDSClientManager defaultClient].file getDownloadUrl:request];
        expect(apiTask).toNot.beNil();
        waitUntil(^(DoneCallback done) {
            [apiTask setResponseBlock:^(PDSAPIGetDownloadUrlResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                expect(requestError).to.beNil();
                expect(result.url).toNot.beNil();
                done();
            }];
        });
    });
});

SpecEnd
