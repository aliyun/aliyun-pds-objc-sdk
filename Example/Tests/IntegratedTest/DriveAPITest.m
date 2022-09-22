//
//  DriveAPITest.m
//  pds-sdk-objc_Tests
//
//  Created by issuser on 2022/5/23.
//  Copyright © 2022 turygo. All rights reserved.
//

#import "PDSTestConfig.h"

@import PDS_SDK;

SpecBegin(DriveAPI)

__block PDSTestConfig *testConfig;
__block PDSAPICreateDriveRequest *createDriveRequest;
__block PDSAPIDeleteDriveRequest *deleteDriveRequest;
__block PDSAPIUpdateDriveRequest *updateDriveRequest;
__block PDSAPIGetDriveRequest *getDriveRequest;
__block PDSAPIGetDefaultDriveRequest *getDefaultRequest;
__block PDSAPIListDriveRequest *listDriveRequest;
__block PDSAPIListMyDrivesRequest *myDrivesRequest;

__block PDSAPIRequestTask<PDSAPICreateDriveResponse *> *createDriveTask;
__block PDSAPIRequestTask<PDSAPIDeleteDriveResponse *> *deleteDriveTask;
__block PDSAPIRequestTask<PDSAPIUpdateDriveResponse *> *updateDriveTask;
__block PDSAPIRequestTask<PDSAPIGetDriveResponse *> *getDriveTask;
__block PDSAPIRequestTask<PDSAPIGetDefaultDriveResponse *> *getDefaultDriveTask;
__block PDSAPIRequestTask<PDSAPIListDriveResponse *> *listDriveTask;
__block PDSAPIRequestTask<PDSAPIListMyDrivesResponse *> *myDrivesTask;

__block NSString *domainID;
__block NSString *driveID;
__block NSArray<PDSAPIGetDriveResponse *> *items;

beforeAll(^{
    testConfig = [[PDSTestConfig alloc] init];
});

describe(@"API requests", ^{
    
    it(@"001 create drive", ^{
        createDriveRequest = [[PDSAPICreateDriveRequest alloc] initWithDriveName:@"开发部" driveType:@"normal" encryptMode:@"none" owner:testConfig.owner relativePath:@"" status:@"enabled" storeId:nil totalSize:1024 isDefault:NO ownerType:@"group" description:@"test description example"];
        expect(createDriveRequest).toNot.beNil();
        expect(createDriveRequest.owner).equal(testConfig.owner);
        waitUntil(^(DoneCallback done) {
            createDriveTask = [[PDSClientManager defaultClient].drive createDrive:createDriveRequest];
            [createDriveTask setResponseBlock:^(PDSAPICreateDriveResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                domainID = result.domainID;
                driveID = result.driveID;
                expect(result.domainID).toNot.beNil();
                expect(requestError).beNil();
                done();
            }];
        });
    });
    
    it(@"002 update drive", ^{
        updateDriveRequest = [[PDSAPIUpdateDriveRequest alloc] initWithDriveID:testConfig.driveID driveName:@"闫力" encryptDataAccess:NO encryptMode:@"none" status:@"enabled" totalSize:5368709120 driveDescription:@"Created by system NO"];
        expect(updateDriveRequest).toNot.beNil();
        waitUntil(^(DoneCallback done) {
            updateDriveTask = [[PDSClientManager defaultClient].drive updateDrive:updateDriveRequest];
            [updateDriveTask setResponseBlock:^(PDSAPIUpdateDriveResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                domainID = result.domainID;
                driveID = result.driveID;
                expect(result.domainID).toNot.beNil();
                expect(requestError).beNil();
                done();
            }];
        });
    });
    
    it(@"003 get drive", ^{
        getDriveRequest = [[PDSAPIGetDriveRequest alloc] initWithDriveId:testConfig.driveID];
        expect(getDriveRequest).toNot.beNil();
        expect(getDriveRequest.driveID).equal(testConfig.driveID);
        waitUntil(^(DoneCallback done) {
            getDriveTask = [[PDSClientManager defaultClient].drive getDrive:getDriveRequest];
            [getDriveTask setResponseBlock:^(PDSAPIGetDriveResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                domainID = result.domainID;
                driveID = result.driveID;
                expect(result.domainID).toNot.beNil();
                expect(requestError).beNil();
                done();
            }];
        });
    });

    it(@"004 get default drive", ^{
        getDefaultRequest = [[PDSAPIGetDefaultDriveRequest alloc] initWithUserId:testConfig.userID];
        expect(getDefaultRequest).toNot.beNil();
        expect(getDefaultRequest.userId).equal(testConfig.userID);
        waitUntil(^(DoneCallback done) {
            getDefaultDriveTask = [[PDSClientManager defaultClient].drive getDefaultDrive:getDefaultRequest];
            [getDefaultDriveTask setResponseBlock:^(PDSAPIGetDefaultDriveResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                domainID = result.domainID;
                driveID = result.driveID;
                expect(result.domainID).toNot.beNil();
                expect(requestError).beNil();
                done();
            }];
        });
    });

    it(@"005 list drives", ^{
        listDriveRequest = [[PDSAPIListDriveRequest alloc] initWithLimit:10 marker:@"" owner:testConfig.owner];
        expect(listDriveRequest).toNot.beNil();
        expect(listDriveRequest.owner).equal(testConfig.owner);
        waitUntil(^(DoneCallback done) {
            listDriveTask = [[PDSClientManager defaultClient].drive listDrive:listDriveRequest];
            [listDriveTask setResponseBlock:^(PDSAPIListDriveResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                items = result.items;
                expect(requestError).beNil();
                done();
            }];
        });
    });

    it(@"006 my drives", ^{
        myDrivesRequest = [[PDSAPIListMyDrivesRequest alloc] initWithLimit:10 marker:@""];
        expect(myDrivesRequest).toNot.beNil();
        waitUntil(^(DoneCallback done) {
            myDrivesTask = [[PDSClientManager defaultClient].drive myDrivesDrive:myDrivesRequest];
            [myDrivesTask setResponseBlock:^(PDSAPIListMyDrivesResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                items = result.items;
                expect(requestError).beNil();
                done();
            }];
        });
    });
    
    it(@"007 delete drive", ^{
        deleteDriveRequest = [[PDSAPIDeleteDriveRequest alloc] initWithDriveId:testConfig.driveID];//20221 10570

        waitUntil(^(DoneCallback done) {
            deleteDriveTask = [[PDSClientManager defaultClient].drive deleteDrive:deleteDriveRequest];
            [deleteDriveTask setResponseBlock:^(PDSAPIDeleteDriveResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                expect(requestError).toNot.beNil();
                done();
            }];
        });
    });
});

SpecEnd
