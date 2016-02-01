//
//  Compatibility.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SILENCE_DEPRECATION(expr)                                   \
do {                                                                \
_Pragma("clang diagnostic push")                                    \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")   \
expr;                                                               \
_Pragma("clang diagnostic pop")                                     \
} while(0)

#define SILENCE_IOS8_DEPRECATION(expr) SILENCE_DEPRECATION(expr)

/**
* iOS8 -> iOS7
*/
@interface Compatibility : NSObject

+ (void)registerForNotifications;
+ (NSString *)currencySymbol;

@end
