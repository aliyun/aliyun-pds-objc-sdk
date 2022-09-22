//
//  SDPopoverAnimator.h
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/27.
//  Copyright © 2022 turygo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDHeader.h"


NS_ASSUME_NONNULL_BEGIN

@interface SDPopoverAnimator : NSObject<UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>

+ (instancetype)popoverAnimator;

- (void)setBottomViewHeight:(CGFloat)height;

@end


@interface SDPresentationController : UIPresentationController
@property(nonatomic,assign)CGSize           presentedSize;
@property(nonatomic,assign)CGFloat          presentedHeight;
@property(nonatomic,strong)UIView           *coverView;
@end

NS_ASSUME_NONNULL_END
