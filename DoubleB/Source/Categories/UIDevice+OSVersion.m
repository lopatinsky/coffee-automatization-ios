//
//  UIDevice+UIDevice_OSVersion.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "UIDevice+OSVersion.h"

@implementation UIDevice (OSVersion)

+ (BOOL)systemVersionEqualsTo:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame;
}

+ (BOOL)systemVersionGreaterThan:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending;
}

+ (BOOL)systemVersionGreaterOrEqualsThan:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending;
}

+ (BOOL)systemVersionLessThan:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending;
}

+ (BOOL)systemVersionLessOrEqualsThan:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedDescending;
}

@end
