//
//  ViewManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 11.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "ViewManager.h"

@implementation ViewManager

+ (NSString *)valueFromPropertyListByKey:(NSString *)key {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSDictionary *companyInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    return [[companyInfo objectForKey:@"AppConfiguration"] objectForKey:key];
}

+ (NSDictionary *)menuIconsConentModes {
    return @{@"Fill": @(UIViewContentModeScaleAspectFill),
             @"Fit": @(UIViewContentModeScaleAspectFit),
             @"Default": @(UIViewContentModeScaleAspectFill),
             };
}

+ (UIViewContentMode)defaultMenuPositionIconsContentMode{
    UIViewContentMode mode = [[self menuIconsConentModes][[self valueFromPropertyListByKey:@"MenuPositionIconsContentMode"] ?: @"Default"] intValue];
    return mode;
}

+ (UIViewContentMode)defaultMenuCategoryIconsContentMode{
    UIViewContentMode mode = [[self menuIconsConentModes][[self valueFromPropertyListByKey:@"MenuCategoryIconsContentMode"] ?: @"Default"] intValue];
    return mode;
}

+ (UIImage *)basketImageMenuPosition {
    NSString *imageName = [self valueFromPropertyListByKey:@"MenuPositionBasketImage"];
    if (imageName) {
        return [UIImage imageNamed:imageName];
    } else {
        return nil;
    }
}

@end
