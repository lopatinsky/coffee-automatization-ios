//
//  CAGradientLayer+Helper.m
//  DoubleB
//
//  Created by Ощепков Иван on 20.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "CAGradientLayer+Helper.h"

@implementation CAGradientLayer(Helper)

+ (CAGradientLayer *)gradientForFrame:(CGRect)frame fromColor:(UIColor *)color1 point:(CGPoint)point1
                      toColor:(UIColor *)color2 point:(CGPoint)point2 {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.colors = @[(id)color1.CGColor, (id)color2.CGColor];
    gradient.startPoint = point1;
    gradient.endPoint = point2;
    return gradient;
}

@end
