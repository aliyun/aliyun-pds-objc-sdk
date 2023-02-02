//
//  PDSAPIGetDefaultDriveRequest.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPIGetDefaultDriveRequest.h"
#import "PDSAPIGetDefaultDriveResponse.h"

@implementation PDSAPIGetDefaultDriveRequest

- (instancetype)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (NSString *)endPoint {
    return @"/v2/drive/get_default_drive";
}

- (Class<PDSSerializable>)responseClass {
    return [PDSAPIGetDefaultDriveResponse class];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"userId":@"user_id"
    };
}

@end
