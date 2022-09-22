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

#import "PDSTestConfig.h"
#import "PDSTestConfig+DownloadTask.h"
@import PDS_SDK;

SpecBegin(FileAPI)
__block PDSTestConfig *testConfig;
__block PDSAPICompleteFileRequest *completeFileRequest;
__block PDSAPICreateFileRequest *createFileRequest;
__block PDSAPIDeleteFileRequest *deleteFileRequest;
__block PDSAPIUpdateFileRequest *updateFileRequest;
__block PDSAPIGetFileRequest *getFileRequest;
__block PDSAPIGetDownloadUrlRequest *getDownloadUrlRequest;
__block PDSAPIRequestTask<PDSAPICreateFileResponse *> *createFileTask;
__block PDSAPIRequestTask<PDSAPICompleteFileResponse *> *completeFileAPITask;
__block PDSAPIRequestTask<PDSAPIDeleteFileResponse *> *deleteFileAPITask;
__block PDSAPIRequestTask<PDSAPIUpdateFileResponse *> *updateFileAPITask;
__block PDSAPIRequestTask<PDSAPIGetFileResponse *> *getFileAPITask;
__block PDSAPIRequestTask<PDSAPISearchFileResponse *> *searchFileAPITask;
__block PDSAPIRequestTask<PDSAPIMoveFileResponse *> *moveFileAPITask;
__block PDSAPIRequestTask<PDSAPICopyFileResponse *> *copyFileAPITask;
__block PDSAPIRequestTask<PDSAPIGetDownloadUrlResponse *> *getDownloadUrlApiTask;
__block NSString *fileID;
__block NSString *uploadID;
__block NSString *fileName;
beforeAll(^{
    testConfig = [PDSTestConfig new];
    fileName = [[NSUUID UUID] UUIDString];
});

describe(@"API requests", ^{
    it(@"001 create file", ^{
        createFileRequest = [[PDSAPICreateFileRequest alloc] initWithShareID:nil driveID:testConfig.driveID parentFileID:testConfig.parentID fileName:fileName fileID:nil fileSize:0 hashValue:nil preHashValue:nil sectionSize:4000 sectionCount:0 checkNameMode:nil shareToken:nil type: PDSAPICreateFileTypeFolder];
        waitUntil(^(DoneCallback done) {
            createFileTask = [[PDSClientManager defaultClient].file createFile:createFileRequest];
            [createFileTask setResponseBlock:^(PDSAPICreateFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                fileID = result.fileId;
                uploadID = result.uploadId;
                expect(result.fileId).toNot.beNil();
                expect(requestError).beNil();
                done();
            }];
        });
    });
    
    it(@"002 complete file", ^{
        completeFileRequest = [[PDSAPICompleteFileRequest alloc] initWithShareID:nil
                                                                         driveID:testConfig.driveID
                                                                          fileID:fileID
                                                                        uploadID:uploadID
                                                                    parentFileID:testConfig.parentID
                                                                        fileName:fileName
                                                                     contentType:nil
                                                                      shareToken:nil];
        expect(completeFileRequest).toNot.beNil();
        expect(completeFileRequest.driveID).equal(testConfig.driveID);
        expect(completeFileRequest.driveID).toNot.beNil();
        expect(completeFileRequest.fileID).equal(fileID);
        expect(completeFileRequest.fileID).toNot.beNil();
        expect(completeFileRequest.fileName).equal(fileName);
        expect(completeFileRequest.fileName).toNot.beNil();
        
        completeFileAPITask = [[PDSClientManager defaultClient].file completeFile:completeFileRequest];
        expect(completeFileAPITask).toNot.beNil();
        waitUntil(^(DoneCallback done) {
            [completeFileAPITask setResponseBlock:^(PDSAPICompleteFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                expect(requestError).to.beNil();
                expect(result.fileID).toNot.beNil();
                done();
            }];
        });
    });
    
    it(@"003 update file", ^{
        updateFileRequest = [[PDSAPIUpdateFileRequest alloc] initWithFileID:fileID
                                                                    driveID:testConfig.driveID
                                                                       name:nil
                                                                       desc:@"test"
                                                                     hidden:NO
                                                                encryptMode:nil
                                                                    starred:NO
                                                             customIndexKey:nil
                                                                     labels:nil
                                                                   userMeta:nil];
        expect(updateFileRequest).toNot.beNil();
        expect(updateFileRequest.desc).equal(@"test");
        expect(updateFileRequest.fileID).equal(fileID);
        expect(updateFileRequest.driveID).equal(testConfig.driveID);
        updateFileAPITask = [[PDSClientManager defaultClient].file updateFile:updateFileRequest];
        waitUntil(^(DoneCallback done) {
            [updateFileAPITask setResponseBlock:^(PDSAPIUpdateFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                expect(result.desc).equal(@"test");
                expect(requestError).to.beNil();
                done();
            }];
        });
    });
    it(@"004 search file", ^{
        NSString *query = [NSString stringWithFormat:@"parent_file_id=\"%@\"",testConfig.parentID];
        PDSAPISearchFileRequest *request = [[PDSAPISearchFileRequest alloc] initWithDriveID:testConfig.driveID
                                                                      imageThumbnailProcess:nil
                                                                            imageUrlProcess:nil
                                                                      videoThumbnailProcess:nil
                                                                                      limit:5
                                                                                     marker:nil
                                                                                    orderBy:@"updated_at DESC"
                                                                                      query:query
                                                                                 expireTime:0];
        expect(request).toNot.beNil();
        expect(request.driveID).equal((testConfig.driveID));
        expect(request.imageThumbnailProcess).beNil();
        expect(request.imageUrlProcess).beNil();
        expect(request.videoThumbnailProcess).beNil();
        expect(request.limit).equal(@(5));
        expect(request.marker).beNil();
        expect(request.orderBy).equal(@"updated_at DESC");
        expect(request.query).equal(query);
        expect(request.expireTime).equal(@(900));
        searchFileAPITask = [[PDSClientManager defaultClient].file searchFile:request];
        waitUntilTimeout(10, ^(DoneCallback done) {
            [searchFileAPITask setResponseBlock:^(PDSAPISearchFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                expect(result.error).beNil();
                PDSAPIGetFileResponse *fileInfo = result.items.firstObject;
                expect(fileInfo).toNot.beNil();
                done();
            }];
        });
    });
    
    it(@"005 get file", ^{
        getFileRequest = [[PDSAPIGetFileRequest alloc] initWithFileID:fileID
                                                              driveID:testConfig.driveID
                                                               fields:nil
                                                imageThumbnailProcess:nil
                                                      imageUrlProcess:nil
                                                videoThumbnailProcess:nil
                                                           expireTime:900];
        expect(getFileRequest).toNot.beNil();
        expect(getFileRequest.fileID).equal(fileID);
        expect(getFileRequest.driveID).equal(testConfig.driveID);
        getFileAPITask = [[PDSClientManager defaultClient].file getFile:getFileRequest];
        waitUntil(^(DoneCallback done) {
            [getFileAPITask setResponseBlock:^(PDSAPIGetFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                expect(result.desc).equal(@"test");
                expect(requestError).to.beNil();
                done();
            }];
        });
    });
    
    it(@"006 copy file", ^{
        NSString *copyFileName = [fileName stringByAppendingPathExtension:@"bak"];
        PDSAPICopyFileRequest *request = [[PDSAPICopyFileRequest alloc] initWithFileID:fileID
                                                                               driveID:testConfig.driveID
                                                                        toParentFileID:testConfig.toMoveParentID
                                                                             toDriveID:testConfig.driveID
                                                                            autoRename:YES
                                                                               newName:copyFileName];
        expect(request).toNot.beNil();
        expect(request.fileID).equal(fileID);
        expect(request.driveID).equal(testConfig.driveID);
        expect(request.toDriveID).equal(testConfig.driveID);
        expect(request.toParentFileID).equal(testConfig.toMoveParentID);
        expect(request.neoName).equal(copyFileName);
        copyFileAPITask = [[PDSClientManager defaultClient].file copyFile:request];
        expect(copyFileAPITask).toNot.beNil();
        waitUntil(^(DoneCallback done) {
            [copyFileAPITask setResponseBlock:^(PDSAPICopyFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                expect(requestError).beNil();
                expect(request.fileID).toNot.beNil();
                done();
            }];
        });
    });
    
    it(@"007 move file", ^{
        PDSAPIMoveFileRequest *request = [[PDSAPIMoveFileRequest alloc] initWithDriveID:testConfig.driveID
                                                                                 fileID:fileID
                                                                         toParentFileID:testConfig.toMoveParentID
                                                                                newName:fileName
                                                                              overwrite:NO];
        expect(request).toNot.beNil();
        expect(request.fileID).equal(fileID);
        expect(request.driveID).equal(testConfig.driveID);
        expect(request.toParentFileID).equal(testConfig.toMoveParentID);
        moveFileAPITask = [[PDSClientManager defaultClient].file moveFile:request];
        waitUntil(^(DoneCallback done) {
            [moveFileAPITask setResponseBlock:^(PDSAPIMoveFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                expect(requestError).beNil();
                expect(result.fileID).toNot.beNil();
                done();
            }];
        });
    });
    
    it(@"099 delete file", ^{
        deleteFileRequest = [[PDSAPIDeleteFileRequest alloc] initWithDriveID:testConfig.driveID
                                                                      fileID:fileID
                                                                 permanently:YES];
            expect(deleteFileRequest).toNot.beNil();
            expect(deleteFileRequest.driveID).equal(testConfig.driveID);
            expect(deleteFileRequest.driveID).toNot.beNil();
            expect(deleteFileRequest.fileID).equal(fileID);
            expect(deleteFileRequest.fileID).toNot.beNil();
            
            deleteFileAPITask = [[PDSClientManager defaultClient].file deleteFile:deleteFileRequest];
            expect(deleteFileAPITask).toNot.beNil();
            waitUntil(^(DoneCallback done) {
                [deleteFileAPITask setResponseBlock:^(PDSAPIDeleteFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                    //PDS的服务端做了限制，启用了回收站，因此这里我们测试肯定失败
                    expect(requestError).toNot.beNil();
                    expect(result.fileID).beNil();
                    done();
                }];
            });
    });
});

describe(@"get download url", ^{
    it(@"001 create request", ^{
        getDownloadUrlRequest = [[PDSAPIGetDownloadUrlRequest alloc] initWithShareID:nil driveID:testConfig.driveID fileID:testConfig.normalDownloadFileID fileName:testConfig.normalDownloadFileName shareToken:nil revisionId:nil];
        expect(getDownloadUrlRequest).toNot.beNil();
        expect(getDownloadUrlRequest.driveID).equal(testConfig.driveID);
        expect(getDownloadUrlRequest.driveID).toNot.beNil();
        expect(getDownloadUrlRequest.fileID).equal(testConfig.normalDownloadFileID);
        expect(getDownloadUrlRequest.fileID).toNot.beNil();
        expect(getDownloadUrlRequest.fileName).equal(testConfig.normalDownloadFileName);
        expect(getDownloadUrlRequest.fileName).toNot.beNil();
    });
    it(@"get response", ^{
        getDownloadUrlApiTask = [[PDSClientManager defaultClient].file getDownloadUrl:getDownloadUrlRequest];
        expect(getDownloadUrlApiTask).toNot.beNil();
        waitUntil(^(DoneCallback done) {
            [getDownloadUrlApiTask setResponseBlock:^(PDSAPIGetDownloadUrlResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                expect(requestError).to.beNil();
                expect(result.url).toNot.beNil();
                done();
            }];
        });
    });
});

SpecEnd
