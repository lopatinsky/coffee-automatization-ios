//
//  UIColor+Brandbook.m
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "UIColor+Brandbook.h"
#import "UIColor+Hex.h"

@implementation UIColor (Brandbook)

+ (UIColor *)db_backgroundColor {
    return [[UIColor alloc] initWithWhite:0.96 alpha:1];
}

+ (UIColor *)db_defaultColor {
    return [ApplicationManager applicationColor];
}

+ (UIColor *)db_defaultColorWithAlpha:(CGFloat)alpha{
    return [[self db_defaultColor] colorWithAlphaComponent:alpha];
}

+ (UIColor *)db_separatorColor{
    return [UIColor colorWithRed:210./255 green:210./255 blue:210./255 alpha:0.5f];
}

+ (UIColor *)db_grayColor{
    return [UIColor colorWithRed:168./255 green:184./255 blue:193./255 alpha:1.];
}

+ (UIColor *)db_defaultTextColor{
    return [UIColor blackColor];
}

+ (UIColor *)db_textGrayColor{
    return  [UIColor colorWithRed:120./255 green:125./255 blue:135./255 alpha:1.];
}

+ (UIColor *)db_errorColor {
    return [self db_errorColor:1.f];
}

+ (UIColor *)db_errorColor:(CGFloat)alpha {
    return [UIColor colorWithRed:255./255 green:87./255 blue:21./255 alpha:alpha];
}

@end
