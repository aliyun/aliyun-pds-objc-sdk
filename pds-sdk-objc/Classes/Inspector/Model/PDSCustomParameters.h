//
//  PDSFileInfo.h
//  PDS_SDK
//
//  Created by issuser on 2022/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSCustomParameters : NSObject

@property (nonatomic, copy) NSString *accessToken;

@property (nonatomic, copy) NSString *driveId;

@property (nonatomic, copy) NSString *pingAddress;

@property (nonatomic, copy) NSString *dnsAddress;

@property (nonatomic, copy) NSString *myDomainAddress;

@end

NS_ASSUME_NONNULL_END
