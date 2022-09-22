//
//  PDSAPIGetDefaultDriveRequest.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIGetDefaultDriveRequest : PDSAPIRequest

@property(nonatomic, copy) NSString *userId;

- (instancetype)initWithUserId:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
