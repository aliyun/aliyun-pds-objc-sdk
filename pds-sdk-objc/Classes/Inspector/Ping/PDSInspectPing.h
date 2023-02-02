//
//  PDSNetPingService.h
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//


#import <PDS_SDK/PDSInspectResult.h>
#import <PDS_SDK/PDSCustomParameters.h>
#import <Foundation/Foundation.h>

typedef void(^PDSReceivePingResponseBlock)(NSString * _Nullable  des, BOOL timeout);
typedef void(^PDSPDSPingServiceFinishBlock)(PDSInspectResult * _Nonnull result);

NS_ASSUME_NONNULL_BEGIN

@class PDSInspectPing;

@protocol PDSInspectPingDelegate <NSObject>

@optional

- (void)didReportSequence:(NSUInteger)sequence packetLoss:(double)lossRate timeout:(BOOL)timeout;

- (void)didStopPing;

@end


@interface PDSInspectPing : NSObject

@property (nonatomic, weak) id<PDSInspectPingDelegate> pingDelegate;

/// 超时时间, default 500ms
@property(nonatomic) double timeoutMilliseconds;

@property(nonatomic) NSInteger  maximumPingTimes;

- (void)startPingHostName:(NSString *)hostName response:(PDSReceivePingResponseBlock)pingResponse finish:(PDSPDSPingServiceFinishBlock)finishBlock;

- (void)cancelPing;

@end

NS_ASSUME_NONNULL_END
