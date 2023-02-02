//
//  PDSNetDetectionTool.m
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/24.
//

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a)-1) | (sizeof(long) - 1))) : sizeof(long))

#import "PDSInspectTool.h"
#import <Reachability/Reachability.h>
#include <resolv.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#import <netinet/in.h>
#include <arpa/inet.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <sys/sysctl.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <netdb.h>
#include "route.h"

@implementation PDSInspectTool

/*
 * 获取当前网络类型
 */
+ (PDSNetworkType)getNetworkType {
    PDSNetworkType netWorkType = PDSNetworkTypeNone;
    @try {
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus status = [reach currentReachabilityStatus];
        
        if (status == ReachableViaWiFi) {
            netWorkType = PDSNetworkTypeWIFI;
        } else if (status == ReachableViaWWAN) {
            
            static CTTelephonyNetworkInfo *netInfo = nil;
            NSString *currentRadioAccessTechnology = nil;
            if (!netInfo) {
                netInfo = [[CTTelephonyNetworkInfo alloc] init];
            }
#ifdef __IPHONE_12_0
            if (@available(iOS 12.1, *)) {
                currentRadioAccessTechnology = netInfo.serviceCurrentRadioAccessTechnology.allValues.lastObject;
            }
#endif
            if (!currentRadioAccessTechnology) {
                currentRadioAccessTechnology = netInfo.currentRadioAccessTechnology;
            }
            
            if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
                netWorkType = PDSNetworkType2G;
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x] || ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD])) {
                netWorkType = PDSNetworkType3G;
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                netWorkType = PDSNetworkType4G;
            } else {
                if (@available(iOS 14.1, *)) {
                    if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyNRNSA]){
                        netWorkType = PDSNetworkType5G;
                    }else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyNR]){
                        netWorkType = PDSNetworkType5G;
                    }
                }else{
                    netWorkType = PDSNetworkTypeUnknown;
                }
            }
        } else {
            netWorkType = PDSNetworkTypeNone;
        }
    } @catch (NSException *exception) {
        NSLog(@"%@: %@", self, exception);
    }
    return netWorkType;
}

/*
 * 获取当前设备ip地址
 */
+ (NSString *)getDeviceIPAddress {
    
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    success = getifaddrs(&interfaces);

    if (success == 0) {  // 0 表示获取成功

        temp_addr = interfaces;
        while (temp_addr != NULL) {
            // Check if interface is en0 which is the wifi connection on the iPhone
            if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"])
            {
                //如果是IPV4地址，直接转化
                if (temp_addr->ifa_addr->sa_family == AF_INET){
                    // Get NSString from C String
                    address = [self formatIPV4Address:((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr];
                }
                
                //如果是IPV6地址
                else if (temp_addr->ifa_addr->sa_family == AF_INET6){
                    address = [self formatIPV6Address:((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr];
                    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) break;
                }
            }

            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);

    //以FE80开始的地址是单播地址
    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) {
        return address;
    } else {
        return @"127.0.0.1";
    }
}

/*
 * 获取当前设备网关地址
 */
+ (NSString *)getGatewayIPAdderss {
    //实现获取当前设备网关地址
    NSString *address = nil;
    
    NSString *gatewayIPV4 = [self getGatewayIPV4Address];
    NSString *gatewayIPV6 = [self getGatewayIPV6Address];
    
    if (gatewayIPV4 != nil) {
        address = gatewayIPV4;
    } else {
        address = gatewayIPV6;
    }
    
    return address;
}

/*
 * 获取运营商名称
 */
+ (NSString *)getCarrierName {
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    if (carrier != NULL) {
        return [carrier carrierName];
    }
    return @"";
}


+ (NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr{
    NSString *address = nil;
    
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if(inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}


+ (NSString *)formatIPV4Address:(struct in_addr)ipv4Addr{
    NSString *address = nil;
    
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if(inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

+ (NSString *)getGatewayIPV4Address
{
    NSString *address = nil;

    /* net.route.0.inet.flags.gateway */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_GATEWAY};
    
    size_t l;
    char *buf, *p;
    struct rt_msghdr *rt;
    struct sockaddr *sa;
    struct sockaddr *sa_tab[RTAX_MAX];
    int i;

    if (sysctl(mib, sizeof(mib) / sizeof(int), 0, &l, 0, 0) < 0) {
        address = @"192.168.0.1";
    }

    if (l > 0) {
        buf = malloc(l);
        if (sysctl(mib, sizeof(mib) / sizeof(int), buf, &l, 0, 0) < 0) {
            address = @"192.168.0.1";
        }

        for (p = buf; p < buf + l; p += rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for (i = 0; i < RTAX_MAX; i++) {
                if (rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }

            if (((rt->rtm_addrs & (RTA_DST | RTA_GATEWAY)) == (RTA_DST | RTA_GATEWAY)) &&
                sa_tab[RTAX_DST]->sa_family == AF_INET &&
                sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                unsigned char octet[4] = {0, 0, 0, 0};
                int i;
                for (i = 0; i < 4; i++) {
                    octet[i] = (((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr >>
                                (i * 8)) &
                               0xFF;
                }
                if (((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    in_addr_t addr =
                        ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                    address = [self formatIPV4Address:*((struct in_addr *)&addr)];
//                    NSLog(@"IPV4address%@", address);
                    break;
                }
            }
        }
        free(buf);
    }
    return address;
}

+ (NSString *)getGatewayIPV6Address
{
    NSString *address = nil;
    
    /* net.route.0.inet.flags.gateway */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET6, NET_RT_FLAGS, RTF_GATEWAY};
    
    size_t l;
    char *buf, *p;
    struct rt_msghdr *rt;
    struct sockaddr_in6 *sa;
    struct sockaddr_in6 *sa_tab[RTAX_MAX];
    int i;
    
    if (sysctl(mib, sizeof(mib) / sizeof(int), 0, &l, 0, 0) < 0) {
        address = @"192.168.0.1";
    }
    
    if (l > 0) {
        buf = malloc(l);
        if (sysctl(mib, sizeof(mib) / sizeof(int), buf, &l, 0, 0) < 0) {
            address = @"192.168.0.1";
        }
        
        for (p = buf; p < buf + l; p += rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr_in6 *)(rt + 1);
            for (i = 0; i < RTAX_MAX; i++) {
                if (rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr_in6 *)((char *)sa + sa->sin6_len);
                } else {
                    sa_tab[i] = NULL;
                }
            }

            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sin6_family == AF_INET6
               && sa_tab[RTAX_GATEWAY]->sin6_family == AF_INET6)
            {
                address = [self formatIPV6Address:((struct sockaddr_in6 *)(sa_tab[RTAX_GATEWAY]))->sin6_addr];
//                NSLog(@"IPV6address%@", address);
                break;
            }
        }
        free(buf);
    }
    return address;
}


+ (NSString *)convertStringForAddressData:(NSData *)address{
    int err;
    NSString *result;
    char hostStr[NI_MAXHOST];

    result = nil;
    if (address != nil) {
        err = getnameinfo([address bytes], (socklen_t)[address length], hostStr, sizeof(hostStr),
                          NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            result = [NSString stringWithCString:hostStr encoding:NSASCIIStringEncoding];
            assert(result != nil);
        }
    }
    return result;
}

+ (nullable NSString*)getCurrentWifiMessage {
    
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                
                //                    NSLog(@"子网掩码:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                
                //                NSLog(@"本地IP:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                
                //                NSLog(@"广播地址:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *)getDiskSpace {
    float totalSpace;
    float totalFreeSpace = 0.0;
    float totalUsedSpace;
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
        totalUsedSpace = totalSpace - totalFreeSpace;
                
        NSString *totalSpaceStr = [[NSString stringWithFormat:@"%.2f",((totalSpace/1000.0f)/1000.0f/1000.0f)]     stringByAppendingString:@"GB"];
        NSString *totalFreeSpaceStr = [[NSString stringWithFormat:@"%.2f",((totalFreeSpace/1000.0f)/1000.0f/1000.0f)] stringByAppendingString:@"GB"];
        return [NSString stringWithFormat:@"磁盘可用容量%@/总容量%@",totalFreeSpaceStr,totalSpaceStr];
    } else {
        return [NSString stringWithFormat:@"Error Obtaining System Memory Info: Domain = %@, Code = %ld",[error domain], (long)[error code]];
    }
}

+ (NSString *)converFileSize:(long long)size {
    long kb = 1024;
    long mb = kb * 1024;
    long gb = mb * 1024;
    
    if (size >= gb) {
        return [NSString stringWithFormat:@"%.1fG",(float)size];
    } else if (size >= mb) {
        float f = (float) size / mb;
        if (f >100) {
            return [NSString stringWithFormat:@"%.0fM",f];
        } else {
            return [NSString stringWithFormat:@"%.1fM",f];
        }
    } else if (size >= kb) {
        float f = (float) size / kb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0fKB",f];
        } else {
            return [NSString stringWithFormat:@"%.1fKB",f];
        }
    } else {
        return [NSString stringWithFormat:@"%lldB",size];
    }
}

@end
