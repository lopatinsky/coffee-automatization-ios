//
//  DeliveryManager.m
//  DoubleB
//
//  Created by Balaban Alexander on 09/06/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfo.h"
#import "DBServerAPI.h"

#import "DBShippingManager.h"

#define kDeliveryAddress @"kDeliveryAddress"
#define kDeliveryApartment @"kDeliveryApartment"
#define kDeliveryCity @"kDeliveryCity"
#define kDeliveryCoordinates @"kDeliveryCoordinates"
#define kDeliveryHome @"kDeliveryHome"

NSString *DeliveryManagerDidRecieveSuggestionsNotification = @"DeliveryManagerDidRecieveSuggestionsNotification";

@interface DBShippingManager()

@property (nonatomic, strong) NSArray *addressSuggestions;
@property (nonatomic, strong) NSTimer *requestSuggestionsTimer;

@end

@implementation DBShippingManager

+ (instancetype)sharedManager {
    static DBShippingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.address = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryAddress] ?: @"";
        instance.apartment = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryApartment] ?: @"";
        instance.city = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryCity] ?: @"";
        instance.home = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryHome] ?: @"";
        instance.coordinates = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryCoordinates] ?: [NSMutableDictionary new];
        instance.addressSuggestions = @[];
        instance.selectedAddress = [NSMutableDictionary dictionaryWithDictionary:@{@"address": [NSMutableDictionary new], @"coordinates": [NSMutableDictionary new]}];
    });
    return instance;
}

- (nonnull NSArray *)arrayOfCities {
    return [[DBCompanyInfo sharedInstance] deliveryCities];
}

- (BOOL)validAddress{
    BOOL valid = YES;
    valid = valid && self.city && self.city.length > 0;
    valid = valid && self.address && self.address.length > 0;
    valid = valid && self.apartment && self.apartment.length > 0;
    
    return valid;
}

- (void)requestSuggestions {
    // request suggestions from backend and push notification about it
    [self.requestSuggestionsTimer invalidate];
    self.requestSuggestionsTimer = nil;
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

- (nonnull NSString *)addressRepresentation {
    return [NSString stringWithFormat:@"%@, %@", self.city ?: @"", self.address];
}

#pragma mark - Setter overrides
- (void)setAddress:(NSString * __nonnull)address {
    _selectedAddress[@"address"][@"street"] = address;
    if (_address == nil) {
        _address = address;
        return;
    }
    
    if (![_address isEqualToString:address]) {
        _address = address;
        if (self.requestSuggestionsTimer) {
            [self.requestSuggestionsTimer invalidate];
            self.requestSuggestionsTimer = nil;
        }
        self.requestSuggestionsTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(requestSuggestions) userInfo:nil repeats:NO];
        [self saveToUserDefaultsValue:address withKey:kDeliveryAddress];
    }
}

- (void)setApartment:(NSString * __nonnull)apartment {
    _apartment = apartment;
    _selectedAddress[@"address"][@"apartment"] = apartment;
    [self saveToUserDefaultsValue:apartment withKey:kDeliveryApartment];
}

- (void)setCity:(NSString * __nonnull)city {
    _city = city;
    _selectedAddress[@"address"][@"city"] = city;
    [self saveToUserDefaultsValue:city withKey:kDeliveryCity];
}

- (void)setCountry:(NSString * __nonnull)country {
    _country = country;
    _selectedAddress[@"address"][@"country"] = country;
}

- (void)setCoordinates:(NSMutableDictionary * __nonnull)coordinates {
    _coordinates = coordinates;
    _selectedAddress[@"coordinates"] = _coordinates;
    [self saveToUserDefaultsValue:[_coordinates copy] withKey:kDeliveryCoordinates];
}

- (void)setHome:(NSString * __nonnull)home {
    _home = home;
    _selectedAddress[@"address"][@"home"] = home;
    [self saveToUserDefaultsValue:_home withKey:kDeliveryHome];
}

- (void)updateCoordinates {
    _selectedAddress[@"coordinates"] = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryCoordinates] ?: [NSDictionary new];
}

- (void)saveToUserDefaultsValue:(NSString *)value withKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
