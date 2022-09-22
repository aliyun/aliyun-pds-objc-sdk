//
//  SDPopViewController.h
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/27.
//  Copyright © 2022 turygo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDHeader.h"

@import PDS_SDK;

NS_ASSUME_NONNULL_BEGIN

@interface SDPopViewController : UIViewController

@property(nonatomic, strong) PDSAPIGetFileResponse *model;

@property(nonatomic, copy) SDCompleteHandle completeHandle;

@end

NS_ASSUME_NONNULL_END
