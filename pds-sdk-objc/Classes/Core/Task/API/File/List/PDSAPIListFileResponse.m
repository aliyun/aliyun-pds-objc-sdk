//
//  PDSAPIListFileResponse.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/26.
//

#import "PDSAPIListFileResponse.h"

@implementation PDSAPIListFileResponse

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"nextMarker": @"next_marker",
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
            @"items" : [PDSAPIGetFileResponse class],
    };
}


@end
