//
//  SDTool.h
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/30.
//  Copyright © 2022 turygo. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface SDTool : NSObject

+ (void)alertWithControll:(UIViewController*)sourceVC title:(NSString *)title message:(NSString*)message placeholder:(NSString *)placeholder completionBlock:(void(^)(NSString *text))block;

@end

NS_ASSUME_NONNULL_END
