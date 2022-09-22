//
//  UIViewController+SDPopover.h
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/27.
//  Copyright © 2022 turygo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDPopoverAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SDPopover)
@property(nonatomic,strong)SDPopoverAnimator *popoverAnimator;

- (void)sdBottomPresentController:(UIViewController *)vc presentedHeight:(CGFloat)height;

@end
NS_ASSUME_NONNULL_END
