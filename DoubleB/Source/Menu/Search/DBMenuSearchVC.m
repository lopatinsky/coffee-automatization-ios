//
//  DBMenuSearchVC.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBMenuSearchVC.h"

@interface DBMenuSearchVC ()<UIViewControllerTransitioningDelegate>

@end

@implementation DBMenuSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//+ (void)presentController:(UIViewController<DBPopupViewControllerContent> *)controller
//              inContainer:(UIViewController *)container
//                     mode:(DBPopupVCAppearanceMode)mode {
//    DBPopupViewController *popupVC = [DBPopupViewController new];
//    popupVC.displayController = controller;
//    popupVC.appearanceMode = mode;
//    popupVC.transitioningDelegate = popupVC;
//    popupVC.modalPresentationStyle = UIModalPresentationCustom;
//    
//    [popupVC beginAppearanceTransition:YES animated:YES];
//    [container presentViewController:popupVC animated:YES completion:^{
//        [popupVC endAppearanceTransition];
//    }];
//}


#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    BOOL reversed = fromViewController == self;
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    
    if (reversed) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.alpha = 0;
            
            self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            self.headerFooterView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            if (_displayController) {
                [_displayController removeFromParentViewController];
                [_displayController.view removeFromSuperview];
            } else if (_displayView) {
                [_displayView removeFromSuperview];
            }
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        [self configLayout:toViewController.view.frame];
        
        [[transitionContext containerView] addSubview:toViewController.view];
        toViewController.view.alpha = 0;
        
        UIImage *snapshot = [fromViewController.view snapshotImage];
        self.bgImageView.image = [snapshot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
        self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.headerFooterView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.alpha = 1;
            
            self.contentView.transform = CGAffineTransformIdentity;
            self.headerFooterView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

@end
