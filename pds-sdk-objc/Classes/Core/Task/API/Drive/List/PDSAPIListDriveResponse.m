//
//  PDSAPIListDriveResponse.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPIListDriveResponse.h"

@implementation PDSAPIListDriveResponse

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"nextMarker": @"next_marker",
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
            @"items" : [PDSAPIGetDriveResponse class],
    };
}

@end
