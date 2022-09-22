//
//  SDPopoverAnimator.m
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/27.
//  Copyright © 2022 turygo. All rights reserved.
//

#import "SDPopoverAnimator.h"

#define kAnimationDuration 0.3

@interface SDPopoverAnimator()
{
    BOOL    _isPresented;
    CGSize  _presentedSize;
}

@property(nonatomic,strong) SDPresentationController *presentationController;

@property(nonatomic,assign) CGFloat                    presentedHeight;

@end

@implementation SDPopoverAnimator

+ (instancetype)popoverAnimator{
    SDPopoverAnimator *popoverAnimator = [[SDPopoverAnimator alloc] init];
    return popoverAnimator;
}

#pragma mark - <UIViewControllerTransitioningDelegatere>
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source{
    SDPresentationController *presentation = [[SDPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    presentation.presentedHeight = _presentedHeight;
    self.presentationController = presentation;
    return presentation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    _isPresented = YES;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    _isPresented = NO;
    return self;
}

#pragma mark - <UIViewControllerAnimatedTransitioning>
- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    _isPresented?[self animationForPresentedView:transitionContext]:[self animationForDismissedView:transitionContext];
}

#pragma mark - animationMethod
// Presented
- (void)animationForPresentedView:(nonnull id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *presentedView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [transitionContext.containerView addSubview:presentedView];
    self.presentationController.coverView.alpha = 0.0f;
    // 设置阴影
    transitionContext.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    transitionContext.containerView.layer.shadowOffset = CGSizeMake(0, 5);
    transitionContext.containerView.layer.shadowOpacity = 0.5f;
    transitionContext.containerView.layer.shadowRadius = 10.0f;
    
    presentedView.transform = CGAffineTransformMakeTranslation(0, _presentedHeight);
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.presentationController.coverView.alpha = 1.0f;
        presentedView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
}
// Dismissed
- (void)animationForDismissedView:(nonnull id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *presentedView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.presentationController.coverView.alpha = 0.0f;
        presentedView.transform = CGAffineTransformMakeTranslation(0, self.presentedHeight);
    } completion:^(BOOL finished) {
        [presentedView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

#pragma mark - Setting
- (void)setBottomViewHeight:(CGFloat)height{
    _presentedHeight = height;
}

@end


@implementation SDPresentationController

- (void)containerViewWillLayoutSubviews{
    [super containerViewWillLayoutSubviews];
    self.presentedView.frame = CGRectMake(0, self.containerView.bounds.size.height - self.presentedHeight, self.containerView.bounds.size.width, self.presentedHeight);
    //添加蒙版
    [self.containerView insertSubview:self.coverView atIndex:0];
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewClick)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

- (void)coverViewClick{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
