//
//  PDSNetDNSService.h
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//

#import <Foundation/Foundation.h>
#import <PDS_SDK/PDSInspectResult.h>

NS_ASSUME_NONNULL_BEGIN


@interface PDSInspectDNS : NSObject

+ (void)getDNSsWithHostName:(NSString *)hostName isIPV6:(BOOL)isIPV6 completeBlock:(void(^)(PDSInspectResult *result))completeBlock ;


@end

NS_ASSUME_NONNULL_END
