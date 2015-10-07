//
//  UIView+RoundedCorners.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 01.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIView+RoundedCorners.h"

@implementation UIView (RoundedCorners)

- (void)setRoundedCorners{
    [self setRoundedCornersWithRadius:6];
}

- (void)setRoundedCornersWithRadius:(CGFloat)radius{
    [self setRoundedCorners:UIRectCornerAllCorners radius:radius];
}

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    CGRect rect = self.bounds;
    
    // Create the path
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.layer.mask = maskLayer;
}

@end
