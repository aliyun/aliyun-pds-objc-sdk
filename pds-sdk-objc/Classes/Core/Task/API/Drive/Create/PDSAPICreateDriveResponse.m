//
//  PDSAPICreateDriveResponse.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPICreateDriveResponse.h"

@implementation PDSAPICreateDriveResponse

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"driveID": @"drive_id",
            @"domainID" : @"domain_id"
    };
}

@end
