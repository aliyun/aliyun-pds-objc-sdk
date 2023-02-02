//
//  PDSNetCurrentDeviceInfo.m
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//

#import "PDSInspectDeviceInfo.h"
#import "PDSInspectTool.h"
#import <sys/utsname.h>


@interface PDSInspectorDeviceInfo ()

@property (nonatomic, copy) NSString *netWork;

@end

@implementation PDSInspectorDeviceInfo

- (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)deviceModelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
}

- (PDSNetWorkType)netWorkType {
    return [PDSInspectTool getNetworkType];
}

- (NSString *)deviceIPAddress {
    return [PDSInspectTool getDeviceIPAddress];
}

- (NSString *)gatewayIPAdderss {
    return [PDSInspectTool getGatewayIPAdderss];
}

- (NSString *)subnetMaskAddress {
    if (self.netWorkType == PDSNetWorkTypeWIFI) {
        return [PDSInspectTool getCurrentWifiMessage];
    }
    return @"";
}

- (NSString *)carrierName {
    return [PDSInspectTool getCarrierName];
}

- (NSString *)diskInfo {
    return [PDSInspectTool getDiskSpace];
}

- (NSString *)netWork {
    NSString *netWork;
    switch (self.netWorkType) {
        case 0:
            netWork = @"未联网";
            break;
        case 1:
            netWork = @"2G网络";
            break;
        case 2:
            netWork = @"3G网络";
            break;
        case 3:
            netWork = @"4G网络";
            break;
        case 4:
            netWork = @"5G网络";
            break;
        case 5:
            netWork = @"wifi网络";
            break;
        default:
            netWork = @"未知网络";
            break;
    }
    return netWork;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n手机系统: %@\nmodel: %@\n当前网络类型: %@\n手机磁盘占用情况: %@\n当前设备ip地址: %@\n当前设备网关地址: %@\n运营商名称: %@\n子网掩码地址：%@",self.systemVersion,self.deviceModelName,self.netWork,self.diskInfo,self.deviceIPAddress,self.gatewayIPAdderss,self.carrierName,self.subnetMaskAddress];
}

@end
