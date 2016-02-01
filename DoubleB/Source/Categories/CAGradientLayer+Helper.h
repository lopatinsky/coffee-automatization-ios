//
//  CAGradientLayer+Helper.h
//  DoubleB
//
//  Created by Ощепков Иван on 20.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

@import Foundation;
@import QuartzCore;

@interface CAGradientLayer(Helper)

+ (CAGradientLayer *)gradientForFrame:(CGRect)frame fromColor:(UIColor *)color1 point:(CGPoint)point1
                              toColor:(UIColor *)color2 point:(CGPoint)point2;

@end
