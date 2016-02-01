//
//  UIDevice+UIDevice_OSVersion.h
//  DoubleB
//
//  Created by Balaban Alexander on 08/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (OSVersion)

+ (BOOL)systemVersionEqualsTo:(NSString *)version;
+ (BOOL)systemVersionGreaterThan:(NSString *)version;
+ (BOOL)systemVersionGreaterOrEqualsThan:(NSString *)version;
+ (BOOL)systemVersionLessThan:(NSString *)version;
+ (BOOL)systemVersionLessOrEqualsThan:(NSString *)version;

@end
