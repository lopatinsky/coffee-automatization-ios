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
#import "DBMenuBonusPosition.h"
#import "Venue.h"
#import "IHSecureStore.h"
#import "DBAPIClient.h"
#import "IHPaymentManager.h"
#import "DBPromoManager.h"
#import "DBClientInfo.h"
#import "DBCompanyInfo.h"
#import "DBShippingManager.h"

//#import <Crashlytics/Crashlytics.h>

NSString* const kDBDefaultsPaymentType = @"kDBDefaultsPaymentType";

@interface OrderManager ()
@end

@implementation OrderManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static OrderManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *lastVenueId = [[NSUserDefaults standardUserDefaults] stringForKey:kDBDefaultsLastSelectedVenue];
        _venue = [Venue venueById:lastVenueId];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flushCache) name:kDBNewOrderCreatedNotification object:nil];
    }
    return self;
}

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

- (void)setVenue:(Venue *)venue{
    if(venue){
        _venue = venue;
        [[NSUserDefaults standardUserDefaults] setObject:venue.venueId forKey:kDBDefaultsLastSelectedVenue];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//- (BOOL)validOrder{
//    BOOL result = true;
//    
//    if([DBDeliverySettings sharedInstance].deliveryType.typeId == DeliveryTypeIdShipping){
//        result = result && [DBShippingManager sharedManager].validAddress;
//    } else {
//        result = result && self.venue;
//    }
//    result = result && !(self.paymentType == PaymentTypeNotSet);
//    result = result && [[DBClientInfo sharedInstance] validClientName];
//    result = result && [[DBClientInfo sharedInstance] validClientPhone];
//    result = result && [[[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsNDASigned] boolValue];
//    result = result && (self.totalCount + [self.bonusPositions count]) > 0;
//    result = result && [DBPromoManager sharedManager].validOrder;
//    
//    return result;
//}


- (void)selectIfPossibleDefaultPaymentType{
    NSArray *availablePaymentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsAvailablePaymentTypes];
    
    if(self.paymentType == PaymentTypeNotSet && [availablePaymentTypes containsObject:@(PaymentTypeCard)]){
        NSDictionary *defaultCard = [[IHSecureStore sharedInstance] defaultCard];
        if(defaultCard){
            self.paymentType = PaymentTypeCard;
        }
    }
    
    if(self.paymentType == PaymentTypeNotSet && [availablePaymentTypes containsObject:@(PaymentTypeCash)]){
        self.paymentType = PaymentTypeCash;
    }
}

#pragma mark - DBManagerProtocol

- (void)flushCache{
    self.venue = nil;
    self.comment = @"";
    self.location = nil;
}

- (void)flushStoredCache{
    [self flushCache];
}

@end
