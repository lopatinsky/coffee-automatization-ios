//
//  UIViewController+Animation.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DBAnimation)

- (void)animateAddProductCircle:(CGFloat)rad
                       fromRect:(CGRect)startFrame fromView:(UIView *)startView
                         toRect:(CGRect)endFrame toView:(UIView *)endView
                     completion:(void (^)())completion;

@end
