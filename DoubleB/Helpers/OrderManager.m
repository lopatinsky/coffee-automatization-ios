//
//  OrderManager.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "OrderManager.h"
#import "OrderItem.h"
#import "DBMenuPosition.h"
#import "Venue.h"
#import "IHSecureStore.h"
#import "DBAPIClient.h"
#import "IHPaymentManager.h"
#import "DBMastercardPromo.h"
#import "DBPromoManager.h"
#import "DBClientInfo.h"

#import <Crashlytics/Crashlytics.h>

NSString* const kDBDefaultsPaymentType = @"kDBDefaultsPaymentType";
NSString* const kDBDefaultsLastSelectedBeverageMode = @"kFBDefaultsLastSelectedBeverageMode";

@interface OrderManager ()<DBPromoManagerUpdateTotalDelegate>
@end

@implementation OrderManager

/**
* Stored in UserDefaults
*/
- (PaymentType)paymentType {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *pt = [defaults objectForKey:kDBDefaultsPaymentType];
    PaymentType paymentType = pt ? (PaymentType)pt.integerValue : PaymentTypeNotSet;
    NSArray *availablePaymentTypes = [defaults objectForKey:kDBDefaultsAvailablePaymentTypes];
    return [availablePaymentTypes containsObject:@(paymentType)] ? paymentType : PaymentTypeNotSet;
}

- (void)setPaymentType:(PaymentType)paymentType {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(paymentType) forKey:kDBDefaultsPaymentType];
    [defaults synchronize];
}

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static OrderManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [DBPromoManager sharedManager].updateTotalDelegate = self;
        self.items = [NSMutableArray array];
        _totalPrice = 0;
        
        _beverageMode = (DBBeverageMode)[[[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsLastSelectedBeverageMode] intValue];
    }
    return self;
}

- (void)setVenue:(Venue *)venue{
    if(venue){
        _venue = venue;
        [[NSUserDefaults standardUserDefaults] setObject:venue.venueId forKey:kDBDefaultsLastSelectedVenue];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setBeverageMode:(DBBeverageMode)beverageMode{
    _beverageMode = beverageMode;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(_beverageMode) forKey:kDBDefaultsLastSelectedBeverageMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)validOrder{
    BOOL result = true;
    
    result = result && self.venue;
    result = result && !(self.paymentType == PaymentTypeNotSet);
    result = result && [[DBClientInfo sharedInstance] validClientName];
    result = result && [[DBClientInfo sharedInstance] validClientPhone];
    result = result && [[[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsNDASigned] boolValue];
    result = result && self.totalCount != 0;
    result = result && [DBPromoManager sharedManager].validOrder;
//    if ([OrderManager sharedManager].paymentType == PaymentTypePersonalAccount) {
//        result = result && [OrderManager sharedManager].totalPrice < [DBMastercardPromo sharedInstance].walletBalans;
//    }
    
    return result;
}

- (void)purgePositions {
    self.items = [NSMutableArray array];
    self.venue = nil;
    self.comment = @"";
    self.location = nil;
    self.orderId = nil;
    
    self.totalPrice = 0;
}

- (void)overridePositions:(NSArray *)items {
    for (OrderItem *item in items) {
        OrderItem *newItem = [item copy];
        [self.items addObject:newItem];
    }
}

- (void)registerNewOrderWithCompletionHandler:(void(^)(BOOL success, NSString *orderId))completionHandler {
    [[DBAPIClient sharedClient] GET:@"order_register.php"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                //NSLog(@"%s %@", __PRETTY_FUNCTION__, responseObject);
                                self.orderId = [NSString stringWithFormat:@"%ld", (long)[responseObject[@"order_id"] integerValue]];
                                
                                [Crashlytics setObjectValue:self.orderId forKey:@"lastRegisteredOrderId"];
                                
                                if (completionHandler) {
                                    completionHandler(YES, self.orderId);
                                }
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
                                if (completionHandler) {
                                    completionHandler(NO, nil);
                                }
                            }];
}

- (NSInteger)addPosition:(DBMenuPosition *)position {
    DBMenuPosition *copyPosition = [position copy];
    OrderItem *itemWithSamePosition;
    
    for(OrderItem *item in self.items){
        if([item.position isEqual:copyPosition]){
            itemWithSamePosition = item;
            break;
        }
    }
    
    if (!itemWithSamePosition) {
        itemWithSamePosition = [[OrderItem alloc] initWithPosition:copyPosition];
        itemWithSamePosition.count = 1;
        [self.items addObject:itemWithSamePosition];
        return 1;
    } else {
        itemWithSamePosition.count ++;
        return itemWithSamePosition.count;
    }
}

- (NSInteger)increaseOrderItemCountAtIndex:(NSInteger)index{
    if(index < 0 || index >= [self.items count])
        return 0;
    
    OrderItem *orderItem = self.items[index];
    orderItem.count++;
    return orderItem.count;

}

- (NSInteger)decreaseOrderItemCount:(NSInteger)index {
    if(index < 0 || index >= [self.items count])
        return 0;
    
    OrderItem *orderItem = self.items[index];
    orderItem.count--;
    if(orderItem.count < 1){
        [self.items removeObject:orderItem];
    }
    
    return orderItem.count;
}

- (NSUInteger)positionsCount {
    return [self.items count];
}

- (NSUInteger)amountOfOrderPositionAtIndex:(NSInteger)index{
    if(index < 0 || index >= [self.items count])
        return 0;
    
    return ((OrderItem *)self.items[index]).count;
}

- (OrderItem *)itemAtIndex:(NSUInteger)index {
    return self.items[index];
}

- (OrderItem *)itemWithPositionId:(NSString *)positionId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"position.positionId == %@", positionId];
    OrderItem *item =[[self.items filteredArrayUsingPredicate:predicate] firstObject];
    
    return item;
}

- (void)removePositionAtIndex:(NSUInteger)index {
    [self.items removeObjectAtIndex:index];
}

- (double)totalPrice {
    if(_totalPrice == 0){
        return self.initialTotalPrice;
    } else {
        return _totalPrice;
    }
}

- (double)initialTotalPrice{
    double total = 0;
    int index = 0;
    for (OrderItem *item in self.items) {
        total += item.totalPrice;
        index++;
    }
    return total;
}

- (NSUInteger)totalCount {
    NSUInteger count = 0;
    for (OrderItem *item in self.items) {
        count += item.count;
    }
    return count;
}

+ (NSUInteger)totalCountForItems:(NSArray *)items{
    NSUInteger count = 0;
    for (OrderItem *item in items) {
        count += item.count;
    }
    return count;
}

- (void)selectIfPossibleDefaultPaymentType{
    NSArray *availablePaymentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsAvailablePaymentTypes];
    
    if(self.paymentType == PaymentTypeNotSet && [availablePaymentTypes containsObject:@(PaymentTypeCard)]){
        NSDictionary *defaultCard = [[IHSecureStore sharedInstance] defaultCard];
        if(defaultCard){
            self.paymentType = PaymentTypeCard;
        }
    }
    
    if (self.paymentType == PaymentTypeNotSet && [availablePaymentTypes containsObject:@(PaymentTypePersonalAccount)]) {
        if ([DBMastercardPromo sharedInstance].walletBalance >= self.totalPrice) {
            self.paymentType = PaymentTypePersonalAccount;
        }
    }
    
    if(self.paymentType == PaymentTypeNotSet && [availablePaymentTypes containsObject:@(PaymentTypeCash)]){
        self.paymentType = PaymentTypeCash;
    }
    
    if(self.paymentType == PaymentTypeNotSet && [availablePaymentTypes containsObject:@(PaymentTypeExtraType)]){
        if([DBMastercardPromo sharedInstance].promoCurrentMugCount >= self.positionsCount){
            self.paymentType = PaymentTypeExtraType;
        }
    }
}

#pragma mark - DBPromoManagerDelegate

- (void)promoManager:(DBPromoManager *)manager didUpdateTotal:(double)totalSum{
    [self willChangeValueForKey:@"totalPrice"];
    _totalPrice = totalSum;
    [self didChangeValueForKey:@"totalPrice"];
}

@end
