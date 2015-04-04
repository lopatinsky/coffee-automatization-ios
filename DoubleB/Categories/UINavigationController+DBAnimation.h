//
//  UINavigationController+DBAnimation.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (DBAnimation)

- (void)animateAddProductFromView:(UIView *)view completion:(void(^)())completion;

@end
