//
//  PDSAPIGetDriveResponse.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPIGetDriveResponse.h"

@implementation PDSAPIGetDriveResponse

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"driveID": @"drive_id",
            @"domainID" : @"domain_id",
            @"driveName":@"drive_name",
            @"driveType":@"drive_type",
            @"encryptMode":@"encrypt_mode",
            @"relativePath":@"relative_path",
            @"storeId":@"store_id",
            @"totalSize":@"total_size",
            @"usedSize":@"used_size",
            @"encryptDataAccess":@"encrypt_data_access",
            @"driveDescription":@"description",
    };
}

@end
