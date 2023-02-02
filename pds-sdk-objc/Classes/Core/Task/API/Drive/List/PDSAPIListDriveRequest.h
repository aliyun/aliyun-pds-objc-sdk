//
//  PDSAPIListDriveRequest.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIListDriveRequest : PDSAPIRequest
//限制数
@property(nonatomic, assign) NSInteger limit;
//
@property(nonatomic, copy) NSString *marker;
///磁盘所有者
@property(nonatomic, copy) NSString *owner;

- (instancetype)initWithLimit:(NSUInteger)limit marker:(NSString *__nullable)marker owner:(NSString *__nullable)owner;

@end

NS_ASSUME_NONNULL_END
