//
//  UIView+RoundedCorners.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 01.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RoundedCorners)

- (void)setRoundedCorners;

- (void)setRoundedCornersWithRadius:(CGFloat)radius;

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius;

@end
