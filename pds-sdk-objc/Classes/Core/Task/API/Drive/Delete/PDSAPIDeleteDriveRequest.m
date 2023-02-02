//
//  PDSAPIDeleteDriveRequest.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPIDeleteDriveRequest.h"
#import "PDSAPIDeleteDriveResponse.h"

@implementation PDSAPIDeleteDriveRequest

- (instancetype)initWithDriveId:(NSString *)driveID {
    self = [super init];
    if (self) {
        _driveID = driveID;
    }
    return self;
}

- (NSString *)endPoint {
    return @"/v2/drive/delete";
}

- (Class<PDSSerializable>)responseClass {
    return [PDSAPIDeleteDriveResponse class];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"driveID":@"drive_id"
    };
}

@end
