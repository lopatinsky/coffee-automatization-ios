//
//  UINavigationController+DBAnimation.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UINavigationController+DBAnimation.h"
#import "UIViewController+DBAnimation.h"

@implementation UINavigationController (DBAnimation)

- (void)animateAddProductFromView:(UIView *)view completion:(void(^)())completion{
    [self animateAddProductCircle:8.f
                         fromRect:view.frame
                         fromView:view.superview
                           toRect:CGRectMake(view.frame.origin.x, 40.f, view.frame.size.width, view.frame.size.height)
                           toView:self.view
                       completion:completion];
}

@end
