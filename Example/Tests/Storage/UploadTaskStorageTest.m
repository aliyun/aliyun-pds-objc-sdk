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
#import "PDSTestStorageContext.h"
#import <PDS_SDK/PDSUploadTaskStorage.h>
#import <FMDB/FMDB.h>
#import <PDS_SDK/PDSFileSubSection.h>


SpecBegin(UploadTaskStorage)
__block PDSTestConfig *testConfig = nil;
__block FMDatabaseQueue *queue = nil;
beforeAll(^{
    testConfig = [[PDSTestConfig alloc] init];
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"PDSSDK.db"];
    queue = [[FMDatabaseQueue alloc] initWithPath:dbPath];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DROP TABLE IF EXISTS upload_task"];
        [db executeUpdate:@"DROP TABLE IF EXISTS task_file_section"];
    }];
});
describe(@"DB init", ^{
    beforeAll(^{
        PDSUploadTaskStorage *uploadTaskStorage = [[PDSUploadTaskStorage alloc] init];
        [uploadTaskStorage setupWithDBQueue:queue];
    });
    it(@"upload task db init success", ^{
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' AND name='upload_task';"];
            expect(resultSet.columnCount).equal(@(1));
            [resultSet close];
        }];
    });
    it(@"file section db init success", ^{
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' AND name='task_file_section';"];
            expect(resultSet.columnCount).equal(@(1));
            [resultSet close];
        }];
    });
    afterAll(^{
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"DROP TABLE IF EXISTS upload_task"];
            [db executeUpdate:@"DROP TABLE IF EXISTS task_file_section"];
        }];
    });
});
describe(@"upload task info", ^{
    __block PDSUploadTaskStorage *uploadTaskStorage = nil;
    beforeAll(^{
        uploadTaskStorage = [[PDSUploadTaskStorage alloc] init];
        [uploadTaskStorage setupWithDBQueue:queue];
    });
    afterEach(^{
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"delete from upload_task"];
            [db executeUpdate:@"delete from task_file_section"];
        }];
    });
    it(@"section set failed without task info", ^{
        NSMutableArray *fileSections = [[NSMutableArray alloc] init];
        PDSFileSubSection *fileSubSection = [[PDSFileSubSection alloc] initWithIdentifier:@"identifier"
                                                                                    index:1
                                                                                     size:100
                                                                                   offset:1
                                                                           taskIdentifier:@"taskIdentifier"];
        [fileSections addObject:fileSubSection];
        [uploadTaskStorage setFileSections:fileSections withTaskStorageInfo:nil];
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQuery:@"select * from task_file_section where identifier = 'identifier'"];
            expect([resultSet next]).to.beFalsy();
            [resultSet close];
        }];
    });
    
    it(@"section set successfully with task info", ^{
        PDSTestStorageContext *storageContext = [[PDSTestStorageContext alloc] init];
        storageContext.taskIdentifier = @"task_identifier";
        storageContext.path = @"/dd";
        storageContext.fileId = @"123";
        storageContext.uploadId = @"123";
        storageContext.sectionSize = 100;
        storageContext.status = 1;
        NSMutableArray *fileSections = [[NSMutableArray alloc] init];
        PDSFileSubSection *fileSubSection = [[PDSFileSubSection alloc] initWithIdentifier:@"identifier"
                                                                                    index:1
                                                                                     size:100
                                                                                   offset:1
                                                                           taskIdentifier:@"task_identifier"];
        [fileSections addObject:fileSubSection];
        [uploadTaskStorage setFileSections:fileSections withTaskStorageInfo:storageContext];
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQuery:@"select * from task_file_section where taskId = ?"
                                               values:@[@"task_identifier"]
                                                error:nil];
            expect([resultSet next]).to.beTruthy();
            expect([resultSet stringForColumn:@"identifier"]).equal(@"identifier");
            expect([resultSet stringForColumn:@"taskId"]).equal(@"task_identifier");
            expect([resultSet intForColumn:@"index"]).equal(@(1));
            expect([resultSet intForColumn:@"size"]).equal(@(100));
            expect([resultSet intForColumn:@"offset"]).equal(@(1));
            [resultSet close];
            resultSet = [db executeQuery:@"select * from upload_task where identifier = ?" values:@[@"task_identifier"] error:nil];
            expect([resultSet next]).to.beTruthy();
            expect([resultSet stringForColumn:@"identifier"]).equal(@"task_identifier");
            expect([resultSet stringForColumn:@"path"]).equal(@"/dd");
            expect([resultSet stringForColumn:@"fileID"]).equal(@"123");
            expect([resultSet stringForColumn:@"uploadId"]).equal(@"123");
            expect([resultSet intForColumn:@"sectionSize"]).equal(@(100));
            expect([resultSet intForColumn:@"status"]).equal(@(1));
            [resultSet close];
        }];
    });
    it(@"get file section and task info", ^{
        [queue inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeUpdate:@"INSERT INTO \"upload_task\" (\"identifier\",\"path\",\"uploadId\",\"fileID\",\"sectionSize\",\"status\") VALUES ('task_identifier','/dd','123','123',100,1);"];
            [db executeUpdate:@"INSERT INTO \"task_file_section\" (\"identifier\",\"taskId\",\"index\",\"size\",\"offset\",\"committed\",\"confirmed\",\"outputUrl\") VALUES ('identifier','task_identifier',1,100,1,0,0,'');"];
        }];
        waitUntil(^(DoneCallback done) {
            [uploadTaskStorage getTaskInfoWithIdentifier:@"task_identifier"
                                              completion:^(NSString *taskIdentifier, NSDictionary *taskInfo, NSArray<PDSFileSubSection *> *fileSections) {
                expect(taskInfo[@"identifier"]).equal(@"task_identifier");
                expect(taskInfo[@"path"]).equal(@"/dd");
                expect(taskInfo[@"sectionSize"]).equal(@(100));
                expect(taskInfo[@"status"]).equal(@(1));
                expect(fileSections.count).to.equal(@(1));
                done();
            }];
        });
    });
    it(@"set file section with task id", ^{
        NSMutableArray *fileSections = [[NSMutableArray alloc] init];
        PDSFileSubSection *fileSubSection = [[PDSFileSubSection alloc] initWithIdentifier:@"identifier"
                                                                                    index:1
                                                                                     size:100
                                                                                   offset:1
                                                                           taskIdentifier:@"task_identifier"];
        [fileSections addObject:fileSubSection];
        [uploadTaskStorage setFileSubSections:fileSections forTaskIdentifier:@"task_identifier"];
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQuery:@"select * from task_file_section where identifier = ?"
                                               values:@[@"identifier"]
                                                error:nil];
            expect([resultSet next]).to.beTruthy();
            expect([resultSet stringForColumn:@"identifier"]).equal(@"identifier");
            expect([resultSet stringForColumn:@"taskId"]).equal(@"task_identifier");
            expect([resultSet intForColumn:@"index"]).equal(@(1));
            expect([resultSet intForColumn:@"size"]).equal(@(100));
            expect([resultSet intForColumn:@"offset"]).equal(@(1));
            [resultSet close];
        }];
    });
    it(@"delete task with task id", ^{
        [queue inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeUpdate:@"INSERT INTO \"upload_task\" (\"identifier\",\"path\",\"uploadId\",\"fileID\",\"sectionSize\",\"status\") VALUES ('task_identifier','/dd','123','123',100,1);"];
            [db executeUpdate:@"INSERT INTO \"task_file_section\" (\"identifier\",\"taskId\",\"index\",\"size\",\"offset\",\"committed\",\"confirmed\",\"outputUrl\") VALUES ('identifier','task_identifier',1,100,1,0,0,'');"];
        }];
        [uploadTaskStorage deleteTaskInfoWithIdentifier:@"task_identifier" force:YES];
        [queue inDatabase:^(FMDatabase *_Nonnull db) {
            FMResultSet *resultSet = [db executeQuery:@"select * from task_file_section where taskId = ?"
                                               values:@[@"task_identifier"]
                                                error:nil];
            expect([resultSet next]).to.beFalsy();
            [resultSet close];
            resultSet = [db executeQuery:@"select * from upload_task where identifier = ?"
                                  values:@[@"task_identifier"]
                                   error:nil];
            expect([resultSet next]).to.beFalsy();
            [resultSet close];
        }];
    });
});

SpecEnd
