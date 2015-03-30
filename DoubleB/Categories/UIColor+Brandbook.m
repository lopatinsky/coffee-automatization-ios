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
    return [UIColor colorWithRed:0 green:95/255.0 blue:78/255.0 alpha:1];
}

+ (UIColor *)db_separatorColor{
    return [UIColor colorWithRed:224./255 green:224./255 blue:224./255 alpha:1.];
}

+ (UIColor *)db_grayColor{
    return [UIColor colorWithRed:168./255 green:184./255 blue:193./255 alpha:1.];
}

@end
