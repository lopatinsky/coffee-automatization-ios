//
//  UIViewController+DBPopupContainer.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "UIViewController+DBPopupContainer.h"

#import "DBPopupViewController.h"
#import <objc/runtime.h>

static char INSTANCE_KEY;

@implementation UIViewController (DBPopupContainer)

- (id)getInstance {
    return objc_getAssociatedObject(self, &INSTANCE_KEY);
}

- (void)setInstance:(id)instance {
    objc_setAssociatedObject(self, &INSTANCE_KEY, instance, OBJC_ASSOCIATION_RETAIN);
}

- (void)presentController:(UIViewController<DBPopupViewControllerContent> *)controller {
    DBPopupViewController *popupVC = [DBPopupViewController new];
    popupVC.displayController = controller;
    popupVC.appearanceMode = DBPopupVCAppearanceModeFooter;
    popupVC.transitioningDelegate = self;
    popupVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self setInstance:popupVC];
    
    [self presentViewController:popupVC animated:YES completion:nil];
}

- (void)presentView:(UIView<DBPopupViewControllerContent> *)view {
    DBPopupViewController *popupVC = [DBPopupViewController new];
    popupVC.displayView = view;
    popupVC.appearanceMode = DBPopupVCAppearanceModeFooter;
    popupVC.transitioningDelegate = self;
    popupVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self setInstance:popupVC];
    
    [self presentViewController:popupVC animated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [self getInstance];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [self getInstance];
}

@end
