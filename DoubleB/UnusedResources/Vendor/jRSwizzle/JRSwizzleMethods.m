//
//  JRSwissleMethods.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "JRSwizzleMethods.h"
#import "JRSwizzle.h"

@implementation JRSwizzleMethods

+ (void)swizzleUIViewDealloc{
    [UIView jr_swizzleMethod:@selector(dealloc) withMethod:@selector(uiview_dealloc) error:Nil];
}

@end
