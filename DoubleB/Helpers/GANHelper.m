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


@implementation GANHelper {

}

+ (void)initialize {
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:[DBCompanyInfo db_companyGoogleAnalyticsKey]];
    [[GAI sharedInstance] setDefaultTracker:tracker];
}

+ (void)analyzeScreen:(NSString *)screen {
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:screen];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createAppView] build]];
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


+ (void)trackNewOrderInfo:(Order *)order{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createTransactionWithId:order.orderId
                                                                                   affiliation:order.venue.venueId
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
    if([IHSecureStore sharedInstance].clientId){
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:1]
                                             value:[IHSecureStore sharedInstance].clientId];
    }
    
    if([[DBClientInfo sharedInstance] validClientPhone]){
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:2]
                                             value:[DBClientInfo sharedInstance].clientPhone];
    }
    
    if([[DBClientInfo sharedInstance] validClientName]){
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:3]
                                             value:[DBClientInfo sharedInstance].clientName];
    }
    
    if([[DBClientInfo sharedInstance] validClientMail]){
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:4]
                                             value:[DBClientInfo sharedInstance].clientMail];
    }
#endif
}


@end