//
//  OrderManager.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "OrderManager.h"
#import "OrderCoordinator.h"
#import "OrderItem.h"
#import "DBMenuPosition.h"
#import "Venue.h"
#import "DBCardsManager.h"
#import "DBAPIClient.h"
#import "IHPaymentManager.h"
#import "DBClientInfo.h"
#import "DBCompanyInfo.h"
#import "ShippingManager.h"

NSString* const kDBDefaultsPaymentType = @"kDBDefaultsPaymentType";
NSString *const kDBDefaultsLastSelectedVenue = @"kDBDefaultsLastSelectedVenue";

@interface OrderManager ()
@property (weak, nonatomic) id<OrderParentManagerProtocol> parentManager;
@end

@implementation OrderManager

- (instancetype)initWithParentManager:(id<OrderParentManagerProtocol>)parentManager{
    self = [super init];
    if (self) {
        _parentManager = parentManager;
        
        NSString *lastVenueId = [[NSUserDefaults standardUserDefaults] stringForKey:kDBDefaultsLastSelectedVenue];
        _venue = [Venue venueById:lastVenueId];
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
    return [[IHPaymentManager sharedInstance] paymentTypeAvailable:paymentType] ? paymentType : PaymentTypeNotSet;
}

- (void)setPaymentType:(PaymentType)paymentType {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(paymentType) forKey:kDBDefaultsPaymentType];
    [defaults synchronize];
    
    [self.parentManager manager:self haveChange:OrderManagerChangePaymentType];
}

- (void)selectIfPossibleDefaultPaymentType{
    if(self.paymentType == PaymentTypeNotSet && [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCard]){
        if([DBCardsManager sharedInstance].defaultCard){
            self.paymentType = PaymentTypeCard;
        }
    }
    
    if(self.paymentType == PaymentTypeNotSet && [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCash]){
        self.paymentType = PaymentTypeCash;
    }
}

- (void)setVenue:(Venue *)venue{
    _venue = venue;
    
    [[NSUserDefaults standardUserDefaults] setObject:venue.venueId forKey:kDBDefaultsLastSelectedVenue];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.parentManager manager:self haveChange:OrderManagerChangeVenue];
}

- (void)setComment:(NSString *)comment {
    _comment = comment;
    
    [self.parentManager manager:self haveChange:OrderManagerChangeComment];
}

- (void)setOddSum:(NSString *)oddSum {
    _oddSum = oddSum;
    
    [self.parentManager manager:self haveChange:OrderManagerChangeOddSum];
}

- (void)setPersonsCount:(NSInteger)personsCount {
    _personsCount = personsCount;
    
    [self.parentManager manager:self haveChange:OrderManagerChangePersonsCount];
}

- (void)setConfirmationType:(ConfirmationType)confirmationType {
    _confirmationType = confirmationType;
    
    [self.parentManager manager:self haveChange:OrderManagerChangeConfirmationType];
}

- (BOOL)ndaAccepted {
    BOOL ndaSigned;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsNDASigned]){
        self.ndaAccepted = [Order allOrders].count > 0;
        ndaSigned = self.ndaAccepted;
    } else {
        ndaSigned = [[NSUserDefaults standardUserDefaults] boolForKey:kDBDefaultsNDASigned];
    }
    
    return ndaSigned;
}

- (void)setNdaAccepted:(BOOL)ndaAccepted {
    [[NSUserDefaults standardUserDefaults] setBool:ndaAccepted forKey:kDBDefaultsNDASigned];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.parentManager manager:self haveChange:OrderManagerChangeNDAAccept];
}

#pragma mark - DBManagerProtocol

- (void)flushCache{
    NSString *lastVenueId = [[NSUserDefaults standardUserDefaults] stringForKey:kDBDefaultsLastSelectedVenue];
    _venue = [Venue venueById:lastVenueId];
    
    self.comment = @"";
    self.location = nil;
}

- (void)flushStoredCache{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs removeObjectForKey:kDBDefaultsLastSelectedVenue];
    [defs removeObjectForKey:kDBDefaultsPaymentType];
    [defs synchronize];
    
    [self flushCache];
}

@end
