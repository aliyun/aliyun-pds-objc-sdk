//
//  PDSAPICreateDriveRequest.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPICreateDriveRequest : PDSAPIRequest
///磁盘名称
@property(nonatomic, copy) NSString *driveName;
///磁盘类型
@property(nonatomic, copy) NSString *driveType;
///默认是none，加密模式
@property(nonatomic, copy) NSString *encryptMode;
///所属磁盘是user_id 或 group_id
@property(nonatomic, copy) NSString *owner;
///Drive存储基于store的相对路径，domain的PathType为OSSPath时返回 样例 : "/a/b/e/"
@property(nonatomic, copy) NSString *relativePath;
///磁盘状态  default  "enabled"   取值: enabled, disabled
@property(nonatomic, copy) NSString *status;
///存储ID
@property(nonatomic, copy) NSString *storeId;
///磁盘空间总量
@property(nonatomic, assign) uint64_t totalSize;
///默认是NO,  是否默认drive, 只允许设置一个默认drive
@property(nonatomic, assign) BOOL isDefault;
///默认值为user ,可选值为 group、user
@property(nonatomic, copy) NSString *ownerType;
///磁盘备注信息
@property(nonatomic, copy) NSString *driveDescription;

- (instancetype)initWithDriveName:(NSString *)driveName driveType:(NSString *__nullable)driveType encryptMode:(NSString *__nullable)encryptMode owner:(NSString *)owner relativePath:(NSString *__nullable)relativePath status:(NSString *__nullable)status storeId:(NSString *__nullable)storeId totalSize:(uint64_t)totalSize isDefault:(BOOL)isDefault ownerType:(NSString *__nullable)ownerType description:(NSString *__nullable)driveDescription;

@end

NS_ASSUME_NONNULL_END
