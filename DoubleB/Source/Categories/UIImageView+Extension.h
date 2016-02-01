//
//  UIImageView+Extension.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 19.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Extension)
- (void)templateImageWithName:(NSString *)name;
- (void)templateImageWithName:(NSString *)name tintColor:(UIColor *)color;
- (void)templateImage:(UIImage *)image;
- (void)templateImage:(UIImage *)image tintColor:(UIColor *)color;

- (void)db_showDefaultImage;
- (void)db_hideDefaultImage;
@end
