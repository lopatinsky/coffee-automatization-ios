//
//  DeliveryManager.m
//  DoubleB
//
//  Created by Balaban Alexander on 09/06/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfo.h"
#import "DBServerAPI.h"

#import "DeliveryManager.h"

#define kDeliveryAddress @"kDeliveryAddress"
#define kDeliveryApartment @"kDeliveryApartment"
#define kDeliveryCity @"kDeliveryCity"

NSString *DeliveryManagerDidRecieveSuggestionsNotification = @"DeliveryManagerDidRecieveSuggestionsNotification";

@interface DeliveryManager()

@property (nonatomic, strong) NSArray *addressSuggestions;
@property (nonatomic, strong) NSTimer *requestSeggestionsTimer;

@end

@implementation DeliveryManager

+ (instancetype)sharedManager {
    static DeliveryManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.address = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryAddress] ?: @"";
        instance.apartment = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryApartment] ?: @"";
        instance.city = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryCity] ?: @"";
        instance.addressSuggestions = @[];
    });
    return instance;
}

- (nonnull NSArray *)arrayOfCities {
    return [[DBCompanyInfo sharedInstance] deliveryCities];
}

- (void)requestSuggestions {
    // request suggestions from backend and push notification about it
    [self.requestSeggestionsTimer invalidate];
    self.requestSeggestionsTimer = nil;
    NSLog(@"request suggestions for address %@, %@", self.city, self.address);
    [DBServerAPI requestAddressSuggestions:@{@"city": self.city, @"street": self.address}
                                  callback:^(BOOL success, NSArray *response) {
                                      self.addressSuggestions = response;
                                      [[NSNotificationCenter defaultCenter] postNotificationName:DeliveryManagerDidRecieveSuggestionsNotification object:nil];
                                  }];
}

- (nonnull NSArray *)addressSuggestions {
    return _addressSuggestions;
}

#pragma mark - Setter overrides
- (void)setAddress:(NSString * __nonnull)address {
    if (_address == nil) {
        _address = address;
        return;
    }
    
    if (![_address isEqualToString:address]) {
        _address = address;
        if (self.requestSeggestionsTimer) {
            [self.requestSeggestionsTimer invalidate];
            self.requestSeggestionsTimer = nil;
        }
        self.requestSeggestionsTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(requestSuggestions) userInfo:nil repeats:NO];
        [self saveToUserDefaultsValue:address withKey:kDeliveryAddress];
    }
}

- (void)setApartment:(NSString * __nonnull)apartment {
    _apartment = apartment;
    
    [self saveToUserDefaultsValue:apartment withKey:kDeliveryApartment];
}

- (void)setCity:(NSString * __nonnull)city {
    _city = city;
    [self saveToUserDefaultsValue:city withKey:kDeliveryCity];
}

- (void)saveToUserDefaultsValue:(NSString *)value withKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
