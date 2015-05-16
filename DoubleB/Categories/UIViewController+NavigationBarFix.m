//
//  UIViewController+NavigationBarFix.m
//  DoubleB
//
//  Created by Balaban Alexander on 14/05/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIViewController+NavigationBarFix.h"

@implementation UIViewController (NavigationBarFix)

- (void)hideNavigationBarShadow {
    UIImageView *shadowView = [self findShadowImageView:self.navigationController.navigationBar];
    shadowView.hidden = YES;
}

- (void)showNavigationBarShadow {
    UIImageView *shadowView = [self findShadowImageView:self.navigationController.navigationBar];
    shadowView.hidden = NO;
}

- (UIImageView *)findShadowImageView:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findShadowImageView:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@end
