//
//  UIColor+Brandbook.h
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Brandbook)

+ (UIColor *)db_defaultColor;
+ (UIColor *)db_defaultColorWithAlpha:(CGFloat)alpha;
+ (UIColor *)db_backgroundColor;
+ (UIColor *)db_separatorColor;
+ (UIColor *)db_grayColor;

+ (UIColor *)db_defaultTextColor;
+ (UIColor *)db_textGrayColor;

+ (UIColor *)db_errorColor;
+ (UIColor *)db_errorColor:(CGFloat)alpha;

@end
