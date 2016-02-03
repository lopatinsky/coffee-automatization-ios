//
// Created by Sergey Pronin on 8/7/14.
// Copyright (c) 2014 Empatika. All rights reserved.
//

#import "GANHelper.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "IHSecureStore.h"
#import "Order.h"
#import "Venue.h"
#import "DBMenuPosition.h"
#import "OrderItem.h"
#import "DBClientInfo.h"


@implementation GANHelper 

+ (void)initialize {
#ifdef DEBUG
//    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:[DBCompanyInfo db_companyGoogleAnalyticsKey]];
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
//    [[GAI sharedInstance] setDefaultTracker:tracker];
#else
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:[ApplicationConfig db_AppGoogleAnalyticsKey]];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] setDefaultTracker:tracker];
#endif
}

+ (void)analyzeScreen:(NSString *)screen {
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:screen];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (void)analyzeEvent:(NSString *)eventName category:(NSString *)category{
    [self analyzeEvent:eventName label:nil category:category];
}

+ (void)analyzeEvent:(NSString *)eventName label:(NSString *)label category:(NSString *)category {
#if TARGET_IPHONE_SIMULATOR
    return;
#else
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                                                        action:eventName
                                                                                         label:label
                                                                                         value:nil] build]];
#endif
}

+ (void)analyzeEvent:(NSString *)eventName number:(NSNumber *)number category:(NSString *)category{
    [self analyzeEvent:eventName label:[number stringValue] category:category];
}

+ (void)analyzeTiming:(NSString *)category
             interval:(NSNumber *)interval
                 name:(NSString *)name{
    [self analyzeTiming:category interval:interval name:name label:nil];
}

+ (void)analyzeTiming:(NSString *)category
             interval:(NSNumber *)interval
                 name:(NSString *)name
                label:(NSString *)label{
    double intervalMillis = [interval doubleValue] * 1000;
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createTimingWithCategory:category
                                                                                       interval:@(intervalMillis)
                                                                                           name:name
                                                                                          label:label] build]];
}


+ (void)trackNewOrderInfo:(Order *)order{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createTransactionWithId:order.orderId
                                                                                   affiliation:order.venueId
                                                                                       revenue:order.total
                                                                                           tax:@(0)
                                                                                      shipping:@(0)
                                                                                  currencyCode:@"RUB"] build]];

    NSUInteger total = 0;
    int index = 0;
    for (OrderItem *item in order.items) {
        total += item.position.price * item.count;
        index++;
    }

    NSString *categoryForAll = @"full";
    int mostExpensivePositionIndex = -1;
    if(total != [order.total integerValue]){
        int price = 0;
        int index = 0;
        for (OrderItem *item in order.items) {
            if(item.position.price > price){
                price = item.position.price;
                mostExpensivePositionIndex = index;
            }
            index++;
        }
    } else {
        if(order.paymentType == PaymentTypeExtraType){
            categoryForAll = @"free";
        }
    }
    
    for(OrderItem *item in order.items){
        NSString *category = [order.items indexOfObject:item] == mostExpensivePositionIndex ? @"discount" : categoryForAll;
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createItemWithTransactionId:order.orderId
                                                                                                  name:item.position.name
                                                                                                   sku:item.position.positionId
                                                                                              category:category
                                                                                                 price:@(item.position.price)
                                                                                              quantity:@(item.count)
                                                                                          currencyCode:@"RUB"] build]];
     }
}

+ (void)trackClientInfo{
#if TARGET_IPHONE_SIMULATOR
    return;
#else
    if ([IHSecureStore sharedInstance].clientId) {
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:1]
                                             value:[IHSecureStore sharedInstance].clientId];
    }
    
    if ([DBClientInfo sharedInstance].clientPhone.valid) {
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:2]
                                             value:[DBClientInfo sharedInstance].clientPhone.value];
    }
    
    if ([DBClientInfo sharedInstance].clientName.valid) {
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:3]
                                             value:[DBClientInfo sharedInstance].clientName.value];
    }
    
    if ([DBClientInfo sharedInstance].clientMail.valid) {
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:4]
                                             value:[DBClientInfo sharedInstance].clientMail.value];
    }
    
    if ([IHSecureStore sharedInstance].clientId.length == 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy.MM.dd";
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:5]
                                             value:[formatter stringFromDate:[NSDate date]]];
    }
    
#endif
}


@end