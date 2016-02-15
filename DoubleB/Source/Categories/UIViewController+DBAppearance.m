//
//  UIViewController+DBAppearance.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 05.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIViewController+DBAppearance.h"

@implementation UIViewController (DBAppearance)

+ (UIViewController *)findBestViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        return [UIViewController findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController *)vc;
        if (svc.viewControllers.count > 0) {
            return [UIViewController findBestViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *svc = (UINavigationController *)vc;
        if (svc.viewControllers.count > 0) {
            return [UIViewController findBestViewController:svc.topViewController];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0) {
            return [UIViewController findBestViewController:svc.selectedViewController];
        } else {
            return vc;
        }
    } else {
        return vc;
    }
}

+ (UIViewController *)currentViewController {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [UIViewController findBestViewController:viewController];
}

- (void)db_setTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    titleLabel.numberOfLines = 2;
    titleLabel.text = title;
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin & UIViewAutoresizingFlexibleRightMargin;
    
    [self.navigationItem setTitleView:titleLabel];
}

@end
