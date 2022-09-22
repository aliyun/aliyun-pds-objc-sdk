//
//  PDSAPIListMyDrivesRequest.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIListMyDrivesRequest : PDSAPIRequest
//限制数
@property(nonatomic, assign) NSInteger limit;
//
@property(nonatomic, copy) NSString *marker;

- (instancetype)initWithLimit:(NSInteger)limit marker:(NSString *__nullable)marker;

@end

NS_ASSUME_NONNULL_END
