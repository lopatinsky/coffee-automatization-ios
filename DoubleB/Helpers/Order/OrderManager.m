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
#import "ShippingManager.h"

NSString* const kDBDefaultsPaymentType = @"kDBDefaultsPaymentType";
NSString *const kDBDefaultsLastSelectedVenue = @"kDBDefaultsLastSelectedVenue";

@interface OrderManager ()
@property (weak, nonatomic) OrderCoordinator *parentManager;
@end

@implementation OrderManager

- (instancetype)initWithParentManager:(OrderCoordinator *)parentManager{
    self = [super init];
    if (self) {
        _parentManager = parentManager;
        
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


- (void)setVenue:(Venue *)venue{
    if(venue){
        _venue = venue;
        [[NSUserDefaults standardUserDefaults] setObject:venue.venueId forKey:kDBDefaultsLastSelectedVenue];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs removeObjectForKey:kDBDefaultsLastSelectedVenue];
    [defs removeObjectForKey:kDBDefaultsPaymentType];
    [defs synchronize];
}

@end
