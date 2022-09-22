//
//  PDSAPICreateDriveRequest.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPICreateDriveRequest.h"
#import "PDSAPICreateDriveResponse.h"
#import <YYModel/NSObject+YYModel.h>

@implementation PDSAPICreateDriveRequest

- (instancetype)initWithDriveName:(NSString *)driveName driveType:(NSString *__nullable)driveType encryptMode:(NSString *__nullable)encryptMode owner:(NSString *)owner relativePath:(NSString *__nullable)relativePath status:(NSString *__nullable)status storeId:(NSString *__nullable)storeId totalSize:(uint64_t)totalSize isDefault:(BOOL)isDefault ownerType:(NSString *__nullable)ownerType description:(NSString *__nullable)driveDescription {
    self = [super init];
    if (self) {
        _driveName = driveName;
        _driveType = driveType;
        _encryptMode = encryptMode;
        _owner = owner;
        _relativePath = relativePath;
        _status = status;
        _storeId = storeId;
        _totalSize = totalSize;
        _isDefault = isDefault;
        _ownerType = ownerType;
        _driveDescription = driveDescription;
    }
    return self;
}

- (NSString *)endPoint {
    return @"/v2/drive/create";
}

- (Class<PDSSerializable>)responseClass {
    return [PDSAPICreateDriveResponse class];
}

- (NSDictionary *)requestParams {
    return [self yy_modelToJSONObject];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"driveName":@"drive_name",
        @"driveType":@"drive_type",
        @"encryptMode":@"encrypt_mode",
        @"relativePath":@"relative_path",
        @"storeId":@"store_id",
        @"totalSize":@"total_size",
        @"isDefault":@"default",
        @"ownerType":@"owner_type",
        @"driveDescription":@"description"
    };
}

@end
