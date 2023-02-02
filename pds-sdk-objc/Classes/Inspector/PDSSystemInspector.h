//
//  PDSNetDiagnoserManager.h
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//

#import <Foundation/Foundation.h>
#import <PDS_SDK/PDSInspectResult.h>
#import <PDS_SDK/PDSInspectHeader.h>

typedef void(^PDSInspectorProgressBlock)(PDSInspectTaskType taskType, PDSInspectTaskStatus status);

typedef void(^PDSInspectorCompletedBlock)(PDSInspectResult * _Nonnull result, BOOL finished);


NS_ASSUME_NONNULL_BEGIN

@class PDSCustomParameters;

@interface PDSSystemInspector : NSObject

+ (instancetype)sharedInstance;

- (void)startCustomParameters:(PDSCustomParameters *)customParameters progress:(PDSInspectorProgressBlock)progressBlock complete:(PDSInspectorCompletedBlock)completeBlock;

- (void)restart;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
