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
    id color = [DBCompanyInfo db_companyDefaultColor];
    
    if ([color isKindOfClass:[NSNumber class]]) {
        return [UIColor fromHex:[color intValue]];
    }
    
    if ([color isKindOfClass:[NSString class]]){
        NSString *hexString = color;
        if ([hexString rangeOfString:@"#"].location == 0)
            hexString = [color stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        if (hexString.length == 6)
            hexString = [NSString stringWithFormat:@"ff%@", hexString];
        
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        [scanner scanHexInt:&rgbValue];
        return [UIColor fromHex:rgbValue];
    }
    
    return nil;
}

+ (UIColor *)db_defaultColorWithAlpha:(CGFloat)alpha{
    return [[self db_defaultColor] colorWithAlphaComponent:alpha];
}

+ (UIColor *)db_separatorColor{
    return [UIColor colorWithRed:224./255 green:224./255 blue:224./255 alpha:0.5f];
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

@end
