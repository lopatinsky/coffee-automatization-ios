//
//  UIViewController+DBPopupContainer.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPopupViewController.h"

@interface UIViewController (DBPopupContainer) <UIViewControllerTransitioningDelegate>

- (void)presentController:(UIViewController<DBPopupViewControllerContent> *)controller;
- (void)presentController:(UIViewController<DBPopupViewControllerContent> *)controller mode:(DBPopupVCAppearanceMode)mode;

- (void)presentView:(UIView<DBPopupViewControllerContent> *)view;
- (void)presentView:(UIView<DBPopupViewControllerContent> *)view mode:(DBPopupVCAppearanceMode)mode;

@end
