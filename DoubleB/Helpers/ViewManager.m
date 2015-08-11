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
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"AppConfiguration.plist"];
    NSDictionary *viewControllersConfig = [NSDictionary dictionaryWithContentsOfFile:path];
    return [viewControllersConfig objectForKey:key];
}

+ (NSDictionary *)menuIconsConentModes {
    return @{@"Scale": @(UIViewContentModeScaleAspectFill),
             @"Fit": @(UIViewContentModeScaleAspectFit),
             @"Default": @(UIViewContentModeScaleAspectFill),
             };
}

+ (UIViewContentMode)defaultMenuIconsContentMode{
    UIViewContentMode mode = [[self menuIconsConentModes][[self valueFromPropertyListByKey:@"MenuIconsContentMode"] ?: @"Default"] intValue];
    return mode;
}

@end
