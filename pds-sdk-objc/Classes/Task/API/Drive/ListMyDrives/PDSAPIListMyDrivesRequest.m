//
//  PDSAPIListMyDrivesRequest.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPIListMyDrivesRequest.h"
#import "PDSAPIListMyDrivesResponse.h"

@implementation PDSAPIListMyDrivesRequest

- (instancetype)initWithLimit:(NSInteger)limit marker:(NSString *__nullable)marker {
    self = [super init];
    if (self) {
        _limit = limit;
        _marker = marker;
    }
    return self;
}

- (NSString *)endPoint {
    return @"/v2/drive/list_my_drives";
}

- (Class<PDSSerializable>)responseClass {
    return [PDSAPIListMyDrivesResponse class];
}

@end
