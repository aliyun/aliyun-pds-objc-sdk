//
//  PDSAPICreateDriveResponse.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import <PDS_SDK/PDSAPIResponse.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPICreateDriveResponse : PDSAPIResponse
///DomainID
@property(nonatomic, copy) NSString *domainID;
///磁盘ID，
@property(nonatomic, copy) NSString *driveID;

@end

NS_ASSUME_NONNULL_END
