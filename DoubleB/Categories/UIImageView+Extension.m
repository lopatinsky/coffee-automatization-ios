//
//  UIImageView+Extension.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 19.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIImageView+Extension.h"

@implementation UIImageView (Extension)
- (void)templateImageWithName:(NSString *)name {
    self.tintColor = [UIColor db_blueColor];
    self.image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}
- (void)templateImageWithName:(NSString *)name tintColor:(UIColor *)color {
    self.tintColor = color;
    self.image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}
@end
