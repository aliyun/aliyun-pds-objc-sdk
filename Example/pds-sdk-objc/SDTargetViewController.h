//
//  SDTargetViewController.h
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/30.
//  Copyright © 2022 turygo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDHeader.h"

@import PDS_SDK;

NS_ASSUME_NONNULL_BEGIN

@interface SDTargetViewController : UIViewController

@property(nonatomic, assign) PDSFileOperationType type;

@property(nonatomic, copy) SDMoveHandle moveHandle;

@property(nonatomic, strong) PDSAPIGetFileResponse *model;

@end

NS_ASSUME_NONNULL_END
