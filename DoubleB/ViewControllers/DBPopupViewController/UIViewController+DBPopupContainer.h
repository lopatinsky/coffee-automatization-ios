//
//  UIViewController+DBPopupContainer.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIViewController (DBPopupContainer) <UIViewControllerTransitioningDelegate>

- (void)present:(UIViewController *)controller;

@end
