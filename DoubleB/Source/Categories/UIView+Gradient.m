//
//  UIView+Gradient.m
//  DoubleB
//
//  Created by Balaban Alexander on 19/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "UIView+Gradient.h"

@implementation UIView (Gradient)

- (void)setGradientWithColors:(NSArray *)colors {
    BOOL layerIsAlreadyExists = NO;
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            if (!CGRectEqualToRect(self.bounds, layer.frame)) {
                [layer removeFromSuperlayer];
            } else {
                layerIsAlreadyExists = YES;
            }
            break;
        }
    }
   
    if (!layerIsAlreadyExists) {
        CAGradientLayer *gradientLayer = [CAGradientLayer new];
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = colors;
        gradientLayer.zPosition = -10;
        [self.layer addSublayer:gradientLayer];
    }
}

@end
