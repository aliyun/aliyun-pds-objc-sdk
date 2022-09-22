//
//  PDSAPIListDriveRequest.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import "PDSAPIListDriveRequest.h"
#import "PDSAPIListDriveResponse.h"

@implementation PDSAPIListDriveRequest

- (instancetype)initWithLimit:(NSUInteger)limit marker:(NSString *__nullable)marker owner:(NSString *__nullable)owner {
    self = [super init];
    if (self) {
        _limit = limit;
        _marker = marker;
        _owner = owner;
    }
    return self;
}

- (NSString *)endPoint {
    return @"/v2/drive/list";
}

- (Class<PDSSerializable>)responseClass {
    return [PDSAPIListDriveResponse class];
}

@end
