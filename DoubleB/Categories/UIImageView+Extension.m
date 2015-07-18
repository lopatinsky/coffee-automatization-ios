//
//  UIImageView+Extension.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 19.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIImageView+Extension.h"

#define DEFAULT_IMAGE_NO_IMAGE_TAG 1428430702

@implementation UIImageView (Extension)

- (void)templateImageWithName:(NSString *)name {
    self.tintColor = [UIColor db_defaultColor];
    self.image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)templateImageWithName:(NSString *)name tintColor:(UIColor *)color {
    self.tintColor = color;
    self.image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)db_showDefaultImage{
    if(![self viewWithTag:DEFAULT_IMAGE_NO_IMAGE_TAG]){
        UIImageView *defaultImageView = [UIImageView new];
        defaultImageView.image = [UIImage imageNamed:@"noimage_icon.png"];
        defaultImageView.contentMode = UIViewContentModeScaleAspectFit;
        defaultImageView.tag = DEFAULT_IMAGE_NO_IMAGE_TAG;
        
        [self addSubview:defaultImageView];
        defaultImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [defaultImageView alignCenterWithView:self];
        
        int size = self.frame.size.height < self.frame.size.width ? self.frame.size.height / 3 : self.frame.size.width / 3;
        [defaultImageView constrainHeight:[NSString stringWithFormat:@"%ld", (long)size]];
        [defaultImageView constrainWidth:[NSString stringWithFormat:@"%ld", (long)size]];
        
        self.backgroundColor = [UIColor colorWithRed:235./255 green:235./255 blue:235./255 alpha:1.0f];
    }
}

- (void)db_hideDefaultImage{
    UIView *defaultImageView = [self viewWithTag:DEFAULT_IMAGE_NO_IMAGE_TAG];
    if(defaultImageView){
        [defaultImageView removeFromSuperview];
    }
    
    self.backgroundColor = [UIColor clearColor];
}
@end
