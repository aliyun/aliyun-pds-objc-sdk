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


#import "PDSTestConfig+DownloadTask.h"
@import PDS_SDK;


SpecBegin(DownloadFileTask)
    __block PDSDownloadTask *downloadTask;
    __block PDSTestConfig *testConfig;
    __block PDSDownloadTask *normalDownloadTask;
    beforeAll(^{
        testConfig = [PDSTestConfig new];
        [testConfig cleanDownloaded];
    });

    describe(@"PDS file download", ^{
        it(@"001 init success", ^{
            NSString *destinationDirPath = [testConfig.downloadDestination stringByAppendingPathComponent:testConfig.downloadFileName];
            PDSDownloadUrlRequest *downloadUrlRequest = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:testConfig.downloadUrl destination:destinationDirPath fileSize:testConfig.downloadSize fileID:testConfig.downloadFileID hashValue:testConfig.downloadHash hashType:PDSFileHashTypeSha1 driveID:testConfig.driveID shareID:nil];
            expect(downloadUrlRequest).toNot.beNil();
            expect(downloadUrlRequest.hashValue).equal(testConfig.downloadHash);
            expect(downloadUrlRequest.fileSize).equal(@(testConfig.downloadSize));
            expect(downloadUrlRequest.fileID).equal(testConfig.downloadFileID);
            expect(downloadUrlRequest.driveID).equal(testConfig.driveID);
        });
        it(@"002 start download", ^{
            NSString *destinationDirPath = [testConfig.downloadDestination stringByAppendingPathComponent:testConfig.downloadFileName];
            PDSDownloadUrlRequest *downloadUrlRequest = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:testConfig.downloadUrl destination:destinationDirPath fileSize:testConfig.downloadSize fileID:testConfig.downloadFileID hashValue:testConfig.downloadHash hashType:PDSFileHashTypeSha1 driveID:testConfig.driveID shareID:nil];
            downloadTask = [[PDSClientManager defaultClient].file downloadUrl:downloadUrlRequest
                                                               taskIdentifier:nil];
            expect(downloadTask).toNot.beNil();
        waitUntilTimeout(30.0, ^(DoneCallback done) {
            [downloadTask setResponseBlock:^(PDSFileMetadata * _Nullable result, PDSRequestError * _Nullable networkError, NSString * _Nonnull taskIdentifier) {
                expect(networkError).to.beNil();
                expect(result).toNot.beNil();
                expect(result.fileID).equal(testConfig.downloadFileID);
                expect(result.fileName).equal(testConfig.downloadFileName);
                expect(result.driveID).equal(testConfig.driveID);
                done();
            }];
        });
        });
        it(@"003 start download again", ^{
            NSString *destinationDirPath = [testConfig.downloadDestination stringByAppendingPathComponent:testConfig.downloadFileName];
            PDSDownloadUrlRequest *downloadUrlRequest = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:testConfig.downloadUrl destination:destinationDirPath fileSize:testConfig.downloadSize fileID:testConfig.downloadFileID hashValue:testConfig.downloadHash hashType:PDSFileHashTypeSha1 driveID:testConfig.driveID shareID:nil];
            downloadTask = [[PDSClientManager defaultClient].file downloadUrl:downloadUrlRequest
                                                               taskIdentifier:nil];
            expect(downloadTask).toNot.beNil();
            waitUntilTimeout(500.0, ^(DoneCallback done) {
                [downloadTask setResponseBlock:^(PDSFileMetadata * _Nullable result, PDSRequestError * _Nullable networkError, NSString * _Nonnull taskIdentifier) {
                    expect(networkError).to.beNil();
                    done();
                }];
            });
        });
    });

describe(@"Normal file download", ^{
    it(@"001 start and suspend", ^{
        NSString *destinationDirPath = [testConfig.downloadDestination stringByAppendingPathComponent:@"edmDrive-0.7.0-mac.dmg"];
        PDSDownloadUrlRequest *downloadUrlRequest = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:@"https://statics.aliyunpds.com/download/edm/desktop/0.7.0/edmDrive-0.7.0-mac.dmg" destination:destinationDirPath fileSize:114499672 fileID:nil hashValue:@"ae6d5e73666feb69ea31c9303c92d8e4828be8c5" hashType:PDSFileHashTypeSha1 driveID:testConfig.driveID shareID:nil];

        normalDownloadTask = [[PDSClientManager defaultClient].file downloadUrl:downloadUrlRequest
                                                           taskIdentifier:nil];
        expect(normalDownloadTask).toNot.beNil();
        waitUntil(^(DoneCallback done) {
            NSTimeInterval delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [normalDownloadTask suspend];
                done();
            });
        });
    });
    it(@"002 resume", ^{
        [normalDownloadTask resume];
        waitUntilTimeout(60, ^(DoneCallback done) {
            [normalDownloadTask setResponseBlock:^(PDSFileMetadata * _Nullable result, PDSRequestError * _Nullable networkError, NSString * _Nonnull taskIdentifier) {
                expect(networkError).to.beNil();
                done();
            }];
        });
    });
});
SpecEnd
