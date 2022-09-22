//
//  PDSAPIUpdateDriveRequest.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPIUpdateDriveRequest.h"
#import "PDSAPIUpdateDriveResponse.h"

@implementation PDSAPIUpdateDriveRequest

- (instancetype)initWithDriveID:(NSString *)driveID driveName:(NSString *__nullable)driveName encryptDataAccess:(BOOL)encryptDataAccess encryptMode:(NSString *__nullable)encryptMode status:(NSString *__nullable)status totalSize:(uint64_t)totalSize driveDescription:(NSString *__nullable)driveDescription {
    self = [super init];
    if (self) {
        _driveID = driveID;
        _driveName = driveName;
        _encryptDataAccess = encryptDataAccess;
        _encryptMode = encryptMode;
        _status = status;
        _totalSize = totalSize;
        _driveDescription = driveDescription;
    }
    return self;
}

- (NSString *)endPoint {
    return @"/v2/drive/update";
}

- (Class<PDSSerializable>)responseClass {
    return [PDSAPIUpdateDriveResponse class];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"driveID":@"drive_id",
        @"driveName":@"drive_name",
        @"encryptDataAccess":@"encrypt_data_access",
        @"encryptMode":@"encrypt_mode",
        @"totalSize":@"total_size",
        @"driveDescription":@"description"
    };
}

@end
