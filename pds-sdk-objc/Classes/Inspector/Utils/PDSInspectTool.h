//
//  PDSNetDetectionTool.h
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/24.
//

#import <Foundation/Foundation.h>
#import "PDSInspectHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDSInspectTool : NSObject

/*
 * 获取当前网络类型
 */
+ (PDSNetWorkType)getNetworkType;

/*
 * 获取当前设备ip地址
 */
+ (NSString *)getDeviceIPAddress;

/*
 * 获取当前设备网关地址
 */
+ (NSString *)getGatewayIPAdderss;

/*
 * 获取子网掩码地址
 */
+ (nullable NSString*)getCurrentWifiMessage;

/*
 * 获取运营商名称
 */
+ (NSString *)getCarrierName;

/*
 * 获取设备磁盘占用情况
 */
+ (NSString *)getDiskSpace;

/*
 * 将ping接收的数据转换成ip地址
 */
+ (NSString *)convertStringForAddressData:(NSData *)address;

/*
 * 将字节转化成B\KB\M\G
 */
+ (NSString *)converFileSize:(long long)size;

@end

NS_ASSUME_NONNULL_END
