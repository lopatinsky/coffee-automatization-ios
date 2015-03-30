//
//  PromoManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 11.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPromoManager.h"
#import "OrderManager.h"
#import "OrderItem.h"
#import "DBMenuPosition.h"
#import "Venue.h"
#import "IHSecureStore.h"
#import "DBAPIClient.h"

@interface DBPromoManager ()
@property (strong, nonatomic) NSNumber *targetTime;

@property (nonatomic) NSInteger lastUpdateNumber;

@end

@implementation DBPromoManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static DBPromoManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lastUpdateNumber = 0;
        self.validOrder = YES;
    }
    return self;
}

- (void)updateInfo{
    [self checkOrder];
}

- (void)notifyTotalSumObserver:(double)total{
    if([self.updateTotalDelegate respondsToSelector:@selector(promoManager:didUpdateTotal:)]){
        [self.updateTotalDelegate promoManager:self didUpdateTotal:total];
    }
}

- (void)checkOrder{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if([IHSecureStore sharedInstance].clientId){
        params[@"client_id"] = [IHSecureStore sharedInstance].clientId;
    }
    
    NSMutableArray *items = [NSMutableArray new];
    for (int i = 0; i < [OrderManager sharedManager].positionsCount; ++i) {
        OrderItem *item = [[OrderManager sharedManager] itemAtIndex:i];
        DBMenuPosition *position = item.position;
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        dict[@"id"] = position.positionId;
        dict[@"quantity"] = @(item.count);
        [items addObject:dict];
    }
    NSData *itemsData = [NSJSONSerialization dataWithJSONObject:items
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *itemsString = [[NSString alloc] initWithData:itemsData encoding:NSUTF8StringEncoding];
    params[@"items"] = itemsString;
    
    
    // Venue
    if([OrderManager sharedManager].venue.venueId){
        params[@"venue_id"] = [OrderManager sharedManager].venue.venueId;
    }
    
    
    // Time
    if([OrderManager sharedManager].time){
        params[@"delivery_time"] = [OrderManager sharedManager].time;
    }
    
    params[@"takeout"] = @([OrderManager sharedManager].beverageMode == DBBeverageModeTakeaway);
    
    // Payment
    if([OrderManager sharedManager].paymentType != PaymentTypeNotSet){
        NSMutableDictionary *payment = [NSMutableDictionary new];
        if ([OrderManager sharedManager].paymentType == PaymentTypeCard) {
            NSDictionary *card = [IHSecureStore sharedInstance].defaultCard;
            payment[@"type_id"] = @1;
            payment[@"mastercard"] = @([[card[@"cardPan"] db_cardIssuer] isEqualToString:kDBCardTypeMasterCard]);
        }
        
        if ([OrderManager sharedManager].paymentType == PaymentTypeCash) {
            payment[@"type_id"] = @0;
        }
        
        if ([OrderManager sharedManager].paymentType == PaymentTypeExtraType) {
            payment[@"type_id"] = @2;
        }
        
        if ([OrderManager sharedManager].paymentType == PaymentTypePersonalAccount) {
            payment[@"type_if"] = @3;
        }

        NSData *paymentData = [NSJSONSerialization dataWithJSONObject:payment
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *paymentString = [[NSString alloc] initWithData:paymentData encoding:NSUTF8StringEncoding];
        params[@"payment"] = paymentString;
    }
    
    NSInteger currentUpdateNumber = self.lastUpdateNumber + 1;
    self.lastUpdateNumber = currentUpdateNumber;
    if ([IHSecureStore sharedInstance].clientId) {
        [[DBAPIClient sharedClient] POST:@"check_order"
                              parameters:params
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                     NSLog(@"%@", responseObject);
                                     
                                     double total = [responseObject[@"total_sum"] doubleValue];
                                     NSMutableArray *itemsInfo = [[NSMutableArray alloc] init];
                                     NSMutableArray *globalPromoMessages = [NSMutableArray new];
                                     NSArray *promos = responseObject[@"promos"];
                                     
                                     for (NSDictionary *item in promos) {
                                         if (item[@"global"]){
                                             [globalPromoMessages addObject:item[@"text"]];
                                         }
                                     }
                                     [OrderManager sharedManager].globalPromos = globalPromoMessages;
                                     [OrderManager sharedManager].globalErrors = responseObject[@"errors"];
                                     
                                     for(NSDictionary *item in responseObject[@"items"]){
                                         NSMutableArray *promosDescr = [[NSMutableArray alloc] init];
                                         
                                         NSPredicate *predicate;
                                         for(NSString *promoId in item[@"promos"]){
                                             predicate = [NSPredicate predicateWithFormat:@"id == %@", promoId];
                                             NSDictionary *promoItem = [[promos filteredArrayUsingPredicate:predicate] firstObject];
                                             if(promoItem && ![promoItem[@"global"] boolValue]){
                                                 [promosDescr addObject:promoItem[@"text"]];
                                             }
                                         }
                                         
                                         [itemsInfo addObject:@{@"id": [item[@"id"] stringValue],
                                                                @"promos": promosDescr,
                                                                @"errors": item[@"errors"]}];
                                     }
                                     
                                     if(self.lastUpdateNumber == currentUpdateNumber){
                                         [self notifyTotalSumObserver:total];
                                         
                                         if([responseObject[@"valid"] boolValue]){
                                             self.validOrder = YES;
                                             
                                             if([self.updateInfoDelegate respondsToSelector:@selector(promoManager:didUpdateInfo:withPromos:)]){
                                                 [self.updateInfoDelegate promoManager:self
                                                                         didUpdateInfo:itemsInfo
                                                                            withPromos:globalPromoMessages];
                                             }
                                         } else {
                                             self.validOrder = NO;
                                             
                                             if([self.updateInfoDelegate respondsToSelector:@selector(promoManager:didUpdateInfo:withErrors:withPromos:)]){
                                                 [self.updateInfoDelegate promoManager:self
                                                                         didUpdateInfo:itemsInfo
                                                                            withErrors:responseObject[@"errors"]
                                                                            withPromos:globalPromoMessages];
                                             }
                                         }
                                     }
                                     
                                     // Analitics
                                     if(responseObject){
                                         NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                                                             options:NSJSONWritingPrettyPrinted
                                                                                               error:nil];
                                         NSString *eventLabel = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                         [GANHelper analyzeEvent:@"promos_update_success" label:eventLabel category:@"Promos"];
                                     }
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     NSLog(@"%@", error);
                                     
                                     self.validOrder = NO;
                                     
                                     if(self.lastUpdateNumber == currentUpdateNumber){
                                         if([self.updateInfoDelegate respondsToSelector:@selector(promoManager:didFailUpdateInfoWithError:)]){
                                             [self.updateInfoDelegate promoManager:self didFailUpdateInfoWithError:error];
                                         }
                                     }
                                     
                                     // Analitics
                                     NSString *eventLabel = [NSString stringWithFormat:@"%ld", (long)error.code];
                                     [GANHelper analyzeEvent:@"promos_update_failure" label:eventLabel category:@"Promos"];
                                 }];
    }
    
    /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        double total = 134;
        NSArray *itemsInfo = @[@{@"id": @"10", @"promos":@[@"Сегодня до 15:00 в кофейне Милютинский, 3 скидка на Аэропресс 20%", @"secondDescription"]}];
        
        for(id observer in self.updateObservers){
            if([observer respondsToSelector:@selector(promoManager:didUpdateInfo:withTotal:)]){
                [observer promoManager:self didUpdateInfo:itemsInfo withTotal:total];
            }
        }
    });*/
}


@end
