//
//  PDSAPIUpdateDriveRequest.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIUpdateDriveRequest : PDSAPIRequest
//磁盘ID，
@property(nonatomic, copy) NSString *driveID;
///磁盘名称
@property(nonatomic, copy) NSString *driveName;
///
@property(nonatomic, assign) BOOL encryptDataAccess;
///加密模式
@property(nonatomic, copy) NSString *encryptMode;
///磁盘状态  样例 : "enabled"default   取值: enabled, disabled
@property(nonatomic, copy) NSString *status;
///磁盘空间总量
@property(nonatomic, assign) uint64_t totalSize;
///磁盘备注信息
@property(nonatomic, copy) NSString *driveDescription;

- (instancetype)initWithDriveID:(NSString *)driveID driveName:(NSString *__nullable)driveName encryptDataAccess:(BOOL)encryptDataAccess encryptMode:(NSString *__nullable)encryptMode status:(NSString *__nullable)status totalSize:(uint64_t)totalSize driveDescription:(NSString *__nullable)driveDescription;

@end

NS_ASSUME_NONNULL_END
