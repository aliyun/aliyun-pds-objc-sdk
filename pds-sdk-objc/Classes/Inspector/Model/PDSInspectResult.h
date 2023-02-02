//
//  PDSNetDetectionResult.h
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/24.
//

#import <Foundation/Foundation.h>
#import "PDSInspectHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDSInspectResult : NSObject

@property (nonatomic, assign) BOOL success;

@property (nonatomic, strong) NSArray<PDSInspectResult *> *results;

@property (nonatomic, copy) NSString *errorMessage;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *context;

- (instancetype)initWithContent:(NSString * _Nullable)content success:(BOOL)success errorMessage:(NSString * _Nullable)errorMessage context:(NSString * _Nullable)context;

- (void)addResult:(PDSInspectResult *)result;


@end

NS_ASSUME_NONNULL_END
