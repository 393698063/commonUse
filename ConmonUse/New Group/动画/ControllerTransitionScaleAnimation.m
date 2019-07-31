//
//  ControllerTransitionScaleAnimation.m
//  ConmonUse
//
//  Created by jorgon(RM) on 2018/10/11.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "ControllerTransitionScaleAnimation.h"

@implementation ControllerTransitionScaleAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toVC = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView * containerView = [transitionContext containerView];
    UIView * fromView = fromVC.view;
    UIView * toView = toVC.view;
    NSLog(@"startAnimation! fromView = %@", fromView);
    NSLog(@"startAnimation! toView = %@", toView);
    for(UIView * view in containerView.subviews){
        NSLog(@"startAnimation! list container subviews: %@", view);
    }
    
    [containerView addSubview:toView];
    
    [[transitionContext containerView] bringSubviewToFront:fromView];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        fromView.alpha = 0.0;
        fromView.transform = CGAffineTransformMakeScale(0.2, 0.2);
        toView.alpha = 1.0;
    } completion:^(BOOL finished) {
        fromView.alpha = 1.0;
        fromView.transform = CGAffineTransformMakeScale(1, 1);
        [transitionContext completeTransition:YES];
        for(UIView * view in containerView.subviews){
            NSLog(@"endAnimation! list container subviews: %@", view);
        }
    }];
}
@end
