//
//  UIViewController+SDPopover.m
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/27.
//  Copyright © 2022 turygo. All rights reserved.
//

#import "UIViewController+SDPopover.h"
#import <objc/runtime.h>

static const char popoverAnimatorKey;

@implementation UIViewController (SDPopover)

- (SDPopoverAnimator *)popoverAnimator{
    return objc_getAssociatedObject(self, &popoverAnimatorKey);
}
- (void)setPopoverAnimator:(SDPopoverAnimator *)popoverAnimator{
    objc_setAssociatedObject(self, &popoverAnimatorKey, popoverAnimator, OBJC_ASSOCIATION_RETAIN) ;
}

- (void)sdBottomPresentController:(UIViewController *)vc presentedHeight:(CGFloat)height {
    
    self.popoverAnimator = [SDPopoverAnimator popoverAnimator];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self.popoverAnimator;
    [self.popoverAnimator setBottomViewHeight:height];

    [self presentViewController:vc animated:YES completion:nil];
}

@end
