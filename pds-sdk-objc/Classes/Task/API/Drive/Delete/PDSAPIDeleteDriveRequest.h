//
//  PDSAPIDeleteDriveRequest.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIDeleteDriveRequest : PDSAPIRequest
//磁盘ID，
@property(nonatomic, copy) NSString *driveID;

- (instancetype)initWithDriveId:(NSString *)driveID;

@end

NS_ASSUME_NONNULL_END
