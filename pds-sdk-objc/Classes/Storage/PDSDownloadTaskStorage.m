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

#import "PDSDownloadTaskStorage.h"
#import "PDSMacro.h"
#import "PDSFileSubSection.h"
#import "PDSDBHelper.h"
#import "PDSLogger.h"
#import <FMDB/FMDB.h>

@interface PDSDownloadTaskStorage ()
@property(nonatomic, strong) FMDatabaseQueue *dbQueue;
@end

@implementation PDSDownloadTaskStorage {

}
- (void)setupWithDBQueue:(FMDatabaseQueue *)dbQueue {
    self.dbQueue = dbQueue;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeStatements:PDSDownloadTaskCreateTableSql];
        [db executeStatements:PDSFileSubSectionCreateTableSql];
    }];
}

- (void)setFileSections:(NSArray <PDSFileSubSection *> *)fileSections withTaskStorageInfo:(id <PDSTaskStorageInfo>)taskStorageInfo {
    if (PDSIsEmpty(taskStorageInfo.taskIdentifier)) {
        return;
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSError *error = nil;
//        NSString *const PDSDownloadTaskInsertTableSql = @"INSERT\n"
//                                                        "\tOR REPLACE INTO \"download_task\" (\n"
//                                                        "\t\t\"identifier\",\n"
//                                                        "\t\t\"path\",\n"
//                                                        "\t\t\"driveID\",\n"
//                                                        "\t\t\"fileID\",\n"
//                                                        "\t\t\"sectionSize\",\n"
//                                                        "\t\t\"status\"\n"
//                                                        "\t)\n"
//                                                        "VALUES\n"
//                                                        "\t(?, ?, ?, ?, ?, ?);";
        [db executeUpdate:PDSDownloadTaskInsertTableSql
                   values:@[
                           taskStorageInfo.taskIdentifier,
                           taskStorageInfo.storageInfo[@"path"] ?: @"",
                           taskStorageInfo.storageInfo[@"driveID"] ?: @"",
                           taskStorageInfo.storageInfo[@"fileID"] ?: @"",
                           taskStorageInfo.storageInfo[@"sectionSize"] ?: @(0),
                           taskStorageInfo.storageInfo[@"status"] ?: @(0),
                   ]
                    error:&error];
        if (error) {
            [PDSLogger logError:[NSString stringWithFormat:@"数据库插入下载任务数据错误:%@",error.localizedDescription]];
            *rollback = YES;
            return;
        }
        [fileSections enumerateObjectsUsingBlock:^(PDSFileSubSection *fileSubSection, NSUInteger idx, BOOL *stop) {
//            ("identifier","taskId","index","size","offset","committed","confirmed","outputUrl")
            [db executeUpdate:PDSFileSubSectionInsertSql
                       values:@[
                               fileSubSection.identifier,
                               fileSubSection.taskIdentifier,
                               @(fileSubSection.index),
                               @(fileSubSection.size),
                               @(fileSubSection.offset),
                               @(fileSubSection.committed),
                               @(fileSubSection.confirmed),
                               fileSubSection.outputUrl ?: @""
                               ]
                        error:nil];
        }];
    }];
}

- (void)setFileSubSections:(NSArray <PDSFileSubSection *> *)fileSubSections forTaskIdentifier:(NSString *)taskIdentifier {
    if (PDSIsEmpty(taskIdentifier) || PDSIsEmpty(fileSubSections)) {
        return;
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [fileSubSections enumerateObjectsUsingBlock:^(PDSFileSubSection *fileSubSection, NSUInteger idx, BOOL *stop) {
//("identifier","taskId","index","size","offset","committed","confirmed","outputUrl")
            BOOL success = [db executeUpdate:PDSFileSubSectionInsertSql
                                      values:@[
                                              fileSubSection.identifier,
                                              taskIdentifier,
                                              @(fileSubSection.index),
                                              @(fileSubSection.size),
                                              @(fileSubSection.offset),
                                              @(fileSubSection.committed),
                                              @(fileSubSection.confirmed),
                                              fileSubSection.outputUrl ?: @""
                                      ] error:nil];
            [PDSLogger logDebug:[NSString stringWithFormat:@"fileSection id:%@,taskId :%@ 数据库插入%@%@",
                                 fileSubSection.identifier,
                                 fileSubSection.taskIdentifier,
                                 success ? @"成功" : @"失败",
                                 success?@"" : [NSString stringWithFormat:@":%@",[db lastErrorMessage]]]];
        }];
    }];
}

- (void)getTaskInfoWithIdentifier:(NSString *)taskIdentifier completion:(PDSTaskStorageGetInfoCompletion)completion {
    if (PDSIsEmpty(taskIdentifier)) {
        if (completion) {
            completion(taskIdentifier, nil, nil);
            return;
        }
    }
    
    __block NSDictionary * taskInfo = nil;
    __block NSMutableArray *fileSubSections = [[NSMutableArray alloc] init];

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *uploadTaskResultSet = [db executeQuery:PDSDownloadTaskSelectTableSql values:@[taskIdentifier] error:nil];
        if(![uploadTaskResultSet next]) {
            [uploadTaskResultSet close];
            return;
        }
        taskInfo = uploadTaskResultSet.resultDictionary;
        [uploadTaskResultSet close];
        FMResultSet *fileSubSectionResultSet = [db executeQuery:PDSFileSubSectionSelectSql values:@[taskIdentifier] error:nil];
        while ([fileSubSectionResultSet next]) {
            PDSFileSubSection *fileSubSection = [[PDSFileSubSection alloc] initWithIdentifier:[fileSubSectionResultSet stringForColumn:@"identifier"]
                                                                                        index:[fileSubSectionResultSet unsignedLongLongIntForColumn:@"index"]
                                                                                         size:(uint64_t) [fileSubSectionResultSet longLongIntForColumn:@"size"]
                                                                                       offset:(uint64_t) [fileSubSectionResultSet longLongIntForColumn:@"offset"]
                                                                               taskIdentifier:[fileSubSectionResultSet stringForColumn:@"taskId"]];
            fileSubSection.outputUrl = [fileSubSectionResultSet stringForColumn:@"outputUrl"];
            fileSubSection.confirmed = [fileSubSectionResultSet boolForColumn:@"confirmed"];
            fileSubSection.committed = fileSubSection.confirmed ? fileSubSection.size : 0;
            [fileSubSections addObject:fileSubSection];
        }
    }];
    if (completion) {
        completion(taskIdentifier,taskInfo,fileSubSections);
    }
}

- (void)deleteTaskInfoWithIdentifier:(NSString *)taskIdentifier force:(BOOL)force {
    if (PDSIsEmpty(taskIdentifier)) {
        return;
    }
    //先找出本地文件删除，再删除数据库
    __block NSDictionary *taskInfo = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *uploadTaskResultSet = [db executeQuery:PDSDownloadTaskSelectTableSql values:@[taskIdentifier] error:nil];
        if (![uploadTaskResultSet next]) {
            [uploadTaskResultSet close];
            return;
        }
        taskInfo = uploadTaskResultSet.resultDictionary;
        [uploadTaskResultSet close];
    }];
    if (taskInfo[@"path"]) {
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:taskInfo[@"path"]];//文件路径
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }

    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:PDSFileSubSectionDeleteSql values:@[taskIdentifier] error:nil];
        [db executeUpdate:PDSDownloadTaskDeleteTableSql values:@[taskIdentifier] error:nil];
    }];
}

@end
