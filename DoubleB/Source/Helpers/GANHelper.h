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

+ (void)initSDK;

+ (void)analyzeScreen:(NSString *)screen;

+ (void)analyzeEvent:(NSString *)eventName category:(NSString *)category;
+ (void)analyzeEvent:(NSString *)eventName label:(NSString *)label category:(NSString *)category;
+ (void)analyzeEvent:(NSString *)eventName number:(NSNumber *)number category:(NSString *)category;

+ (void)analyzeTiming:(NSString *)category interval:(NSNumber *)interval name:(NSString *)name;

+ (void)analyzeTiming:(NSString *)category interval:(NSNumber *)interval name:(NSString *)name label:(NSString *)label;

+ (void)trackNewOrderInfo:(Order *)order;

+ (void)trackClientInfo;

@end