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

#import "PDSDBHelper.h"

// Upload Task
NSString *const PDSUploadTaskCreateTableSql = @"CREATE TABLE IF NOT EXISTS \"upload_task\" ( \"identifier\"\tTEXT NOT NULL UNIQUE, \"path\"\tTEXT, \"uploadId\"\tTEXT, \"fileID\"\tTEXT, \"sectionSize\"\tINTEGER, \"status\"\tINTEGER NOT NULL, PRIMARY KEY(\"identifier\"))";

NSString *const PDSUploadTaskInsertTableSql = @"INSERT OR REPLACE INTO \"upload_task\" (\"identifier\",\"path\",\"uploadId\",\"fileID\",\"sectionSize\",\"status\") VALUES (?,?,?,?,?,?);";

NSString *const PDSUploadTaskSelectTableSql = @"SELECT \"identifier\",\"path\",\"uploadId\",\"fileID\",\"sectionSize\",\"status\" from upload_task WHERE identifier = ?";

NSString *const PDSUploadTaskDeleteTableSql = @"DELETE  FROM upload_task WHERE identifier = ?";

// Download Task
NSString *const PDSDownloadTaskCreateTableSql = @"CREATE TABLE IF NOT EXISTS \"download_task\" (\n"
                                                "\t\"identifier\" TEXT NOT NULL UNIQUE,\n"
                                                "\t\"path\" TEXT,\n"
                                                "\t\"driveID\" TEXT,\n"
                                                "\t\"fileID\" TEXT,\n"
                                                "\t\"sectionSize\" INTEGER,\n"
                                                "\t\"status\" INTEGER NOT NULL,\n"
                                                "\tPRIMARY KEY(\"identifier\")\n"
                                                ")";

NSString *const PDSDownloadTaskInsertTableSql = @"INSERT\n"
                                                "\tOR REPLACE INTO \"download_task\" (\n"
                                                "\t\t\"identifier\",\n"
                                                "\t\t\"path\",\n"
                                                "\t\t\"driveID\",\n"
                                                "\t\t\"fileID\",\n"
                                                "\t\t\"sectionSize\",\n"
                                                "\t\t\"status\"\n"
                                                "\t)\n"
                                                "VALUES\n"
                                                "\t(?, ?, ?, ?, ?, ?);";

NSString *const PDSDownloadTaskSelectTableSql = @"SELECT\n"
                                                "\t\"identifier\",\n"
                                                "\t\"path\",\n"
                                                "\t\"driveID\",\n"
                                                "\t\"fileID\",\n"
                                                "\t\"sectionSize\",\n"
                                                "\t\"status\"\n"
                                                "from\n"
                                                "\tdownload_task\n"
                                                "WHERE\n"
                                                "\tidentifier = ?";

NSString *const PDSDownloadTaskDeleteTableSql = @"DELETE  FROM download_task WHERE identifier = ?";

// File SubSection
NSString *const PDSFileSubSectionCreateTableSql = @"CREATE TABLE IF NOT EXISTS \"task_file_section\" ( \"identifier\"\tTEXT NOT NULL UNIQUE, \"taskId\"\tTEXT NOT NULL, \"index\"\tINTEGER, \"size\"\tINTEGER, \"offset\"\tINTEGER, \"committed\"\tINTEGER, \"confirmed\"\tINTEGER, \"outputUrl\"\tTEXT, PRIMARY KEY(\"identifier\"))";


NSString *const PDSFileSubSectionInsertSql = @"INSERT OR REPLACE INTO \"task_file_section\" (\"identifier\",\"taskId\",\"index\",\"size\",\"offset\",\"committed\",\"confirmed\",\"outputUrl\") "
                                                                     "VALUES (?,?,?,?,?,?,?,?);";

NSString *const PDSFileSubSectionSelectSql = @"SELECT \"identifier\",\"taskId\",\"index\",\"size\",\"offset\",\"committed\",\"confirmed\",\"outputUrl\" from task_file_section WHERE taskId = ? order by \"index\" ASC";

NSString *const PDSFileSubSectionDeleteSql = @"DELETE from task_file_section WHERE taskId = ?";
