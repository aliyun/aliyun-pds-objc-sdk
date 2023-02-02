//
//  PDSNetWorkRequest.h
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//

#import <Foundation/Foundation.h>
#import <PDS_SDK/PDSInspectResult.h>
#import <PDS_SDK/PDSCustomParameters.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PDSFileProgressBlock)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

@interface PDSNetWorkRequest : NSObject

+ (instancetype)sharedInstance;

+ (void)requestBaiduAddressBlock:(void (^)(PDSInspectResult *result))block;

+ (void)postRequestMyDomainAddress:(NSString *)address resonseBlock:(void (^)(PDSInspectResult *result))block;

@end

NS_ASSUME_NONNULL_END
