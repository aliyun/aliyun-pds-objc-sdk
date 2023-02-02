//
//  PDSNetCurrentDeviceInfo.h
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//

#import <Foundation/Foundation.h>
#import <PDS_SDK/PDSInspectHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSInspectorDeviceInfo : NSObject

@property (nonatomic, copy) NSString *systemVersion;

@property (nonatomic, copy) NSString *deviceModelName;

@property (nonatomic, assign) PDSNetWorkType netWorkType;

@property (nonatomic, copy) NSString *deviceIPAddress;

@property (nonatomic, copy) NSString *subnetMaskAddress;

@property (nonatomic, copy) NSString *gatewayIPAdderss;

@property (nonatomic, copy) NSString *carrierName;

@property (nonatomic, copy) NSString *diskInfo;

@end

NS_ASSUME_NONNULL_END
