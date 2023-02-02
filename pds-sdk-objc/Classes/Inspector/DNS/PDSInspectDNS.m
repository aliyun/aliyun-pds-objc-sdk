//
//  PDSNetDNSService.m
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//

#import "PDSInspectDNS.h"
#import "PDSConstants.h"
#include <netdb.h>
#include <arpa/inet.h>
#include <dns.h>
#include <resolv.h>

@implementation PDSInspectDNS


+ (void)getDNSsWithHostName:(NSString *)hostName isIPV6:(BOOL)isIPV6 completeBlock:(void(^)(PDSInspectResult *result))completeBlock {
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    res_state res = malloc(sizeof(struct __res_state));
    int resultInt = res_ninit(res);
    if (resultInt == 0) {
        for (int i = 0; i < res->nscount; i++) {
            NSString *s = [NSString stringWithUTF8String:inet_ntoa(res->nsaddr_list[i].sin_addr)];
            [resultArr addObject:s];
        }
    }
    
//    NSArray *DNSs;
//    if (isIPV6) {
//        DNSs = [self getIPV6DNSWithHostName:hostName];
//    } else {
//        DNSs = [self getIPV4DNSWithHostName:hostName];
//    }
//
//    if (DNSs && DNSs.count > 0) {
//        [resultArr addObjectsFromArray:DNSs];
//    }
    
    PDSInspectResult *result = [[PDSInspectResult alloc] init];
    if (resultArr.count > 0) {
        result.success = YES;
    
    } else {
        result.success = NO;
        result.errorMessage = PDSNetErrorDNSStringKey;
    }
    completeBlock(result);
}

+ (NSArray *)getIPV6DNSWithHostName:(NSString *)hostName
{
    const char *hostN = [hostName UTF8String];
    struct hostent *phot;
    
    @try {
        phot = gethostbyname2(hostN, AF_INET6);
    } @catch (NSException *exception) {
        return nil;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int i = 0;
    while (phot && phot->h_addr_list && phot->h_addr_list[i]) {
        struct in6_addr ip6_addr;
        memcpy(&ip6_addr, phot->h_addr_list[i], sizeof(struct in6_addr));
        NSString *strIPAddress = [self formatIPV6Address: ip6_addr];
        [result addObject:strIPAddress];
        i++;
    }
    
    return [NSArray arrayWithArray:result];
}

+ (NSArray *)getIPV4DNSWithHostName:(NSString *)hostName
{
    const char *hostN = [hostName UTF8String];
    struct hostent *phot;

    @try {
        phot = gethostbyname(hostN);
    } @catch (NSException *exception) {
        return nil;
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];
    int j = 0;
    while (phot && phot->h_addr_list && phot->h_addr_list[j]) {
        struct in_addr ip_addr;
        memcpy(&ip_addr, phot->h_addr_list[j], 4);
        char ip[20] = {0};
        inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));

        NSString *strIPAddress = [NSString stringWithUTF8String:ip];
        [result addObject:strIPAddress];
        j++;
    }

    return [NSArray arrayWithArray:result];
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

@end
