//
// Created by Sergey Pronin on 8/7/14.
// Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Order;

/**
* Google Analytics helper
*/
@interface GANHelper : NSObject

+ (void)analyzeScreen:(NSString *)screen;

+ (void)analyzeEvent:(NSString *)eventName category:(NSString *)category;
+ (void)analyzeEvent:(NSString *)eventName label:(NSString *)label category:(NSString *)category;

+ (void)trackNewOrderInfo:(Order *)order;

+ (void)trackClientInfo;

@end