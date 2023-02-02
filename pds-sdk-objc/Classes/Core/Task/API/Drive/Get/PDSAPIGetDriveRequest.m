//
//  PDSAPIGetDriveRequest.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPIGetDriveRequest.h"
#import "PDSAPIGetDriveResponse.h"

@implementation PDSAPIGetDriveRequest

- (instancetype)initWithDriveId:(NSString *)driveID {
    self = [super init];
    if (self) {
        _driveID = driveID;
    }
    return self;
}

- (NSString *)endPoint {
    return @"/v2/drive/get";
}

- (Class<PDSSerializable>)responseClass {
    return [PDSAPIGetDriveResponse class];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"driveID":@"drive_id"
    };
}

@end
