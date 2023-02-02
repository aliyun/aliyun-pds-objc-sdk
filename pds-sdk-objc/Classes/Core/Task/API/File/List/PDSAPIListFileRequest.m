//
//  PDSAPIListFileRequest.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/26.
//

#import "PDSAPIListFileRequest.h"
#import "PDSAPIListFileResponse.h"

@implementation PDSAPIListFileRequest

- (instancetype)initWithLimit:(NSInteger)limit marker:(NSString * _Nullable)marker driveID:(NSString *)driveID shareId:(NSString * _Nullable)shareId order:(NSString * _Nullable)order fields:(NSString * _Nullable)fields orderDirection:(NSString * _Nullable)orderDirection parentFileID:(NSString *)parentFileID all:(BOOL)all {
    self = [super init];
    if (self) {
        _limit = limit;
        _marker = marker;
        _driveID = driveID;
        _shareId = shareId,
        _order = order;
        _fields = fields;
        _orderDirection = orderDirection;
        _parentFileID = parentFileID;
        _all = all;
    }
    return self;
}

- (NSString *)endPoint {
    return @"/v2/file/list";
}

- (Class<PDSSerializable>)responseClass {
    return [PDSAPIListFileResponse class];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"driveID":@"drive_id",
        @"shareId":@"share_id",
        @"parentFileID":@"parent_file_id",
        @"orderDirection":@"order_direction",
        @"order":@"order_by",
    };
}


@end
