//
//  PDSAPIGetDriveResponse.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import <PDS_SDK/PDSAPIResponse.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIGetDriveResponse : PDSAPIResponse
///磁盘创建者
@property(nonatomic, copy) NSString *creator;
///DomainID
@property(nonatomic, copy) NSString *domainID;
//磁盘ID，
@property(nonatomic, copy) NSString *driveID;
///磁盘名称
@property(nonatomic, copy) NSString *driveName;
///磁盘类型
@property(nonatomic, copy) NSString *driveType;
///加密模式
@property(nonatomic, copy) NSString *encryptMode;
///磁盘所有者
@property(nonatomic, copy) NSString *owner;
///Drive存储基于store的相对路径，domain的PathType为OSSPath时返回 样例 : "/a/b/e/"
@property(nonatomic, copy) NSString *relativePath;
///磁盘状态  样例 : "enabled"default
@property(nonatomic, copy) NSString *status;
///存储ID
@property(nonatomic, copy) NSString *storeId;
///磁盘空间总量
@property(nonatomic, assign) uint64_t totalSize;
///磁盘空间已使用量
@property(nonatomic, assign) uint64_t usedSize;
///
@property(nonatomic, assign) BOOL encryptDataAccess;
///磁盘备注信息
@property(nonatomic, copy) NSString *driveDescription;

@end

NS_ASSUME_NONNULL_END
