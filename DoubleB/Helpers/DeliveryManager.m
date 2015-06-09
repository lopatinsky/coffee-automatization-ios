//
//  DeliveryManager.m
//  DoubleB
//
//  Created by Balaban Alexander on 09/06/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfo.h"

#import "DeliveryManager.h"

#define kDeliveryCity @"kDeliveryCity"
#define kDeliveryStreet @"kDeliveryStreet"
#define kDeliveryHouse @"kDeliveryHouse"
#define kDeliveryCorpus @"kDeliveryCorpus"
#define kDeliveryApartment @"kDeliveryApartment"

NSString *DeliveryManagerDidRecieveSuggestionsNotification = @"DeliveryManagerDidRecieveSuggestionsNotification";

@interface DeliveryManager()

@property (nonatomic, strong) NSArray *addressSuggestions;

@end

@implementation DeliveryManager

+ (instancetype)sharedManager {
    static DeliveryManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.city = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryCity] ?: @"";
        instance.street = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryStreet] ?: @"";
        instance.house = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryHouse] ?: @"";
        instance.corpus = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryCorpus] ?: @"";
        instance.apartment = [[NSUserDefaults standardUserDefaults] objectForKey:kDeliveryApartment] ?: @"";
        instance.addressSuggestions = @[];
    });
    return instance;
}

- (nonnull NSArray *)listOfCities {
    return [[DBCompanyInfo sharedInstance] deliveryCities];
}

- (void)requestSuggestions {
    // request suggestions from backend and push notification about it
    NSLog(@"request suggestions for city %@ and street %@", self.city, self.street);
}

- (nonnull NSArray *)addressSuggestions {
    return self.addressSuggestions;
}

#pragma mark - Setter overrides
- (void)setCity:(NSString * __nonnull)city {
    [self saveToUserDefaultsValue:city withKey:kDeliveryCity];
}

- (void)setStreet:(NSString * __nonnull)street {
    [self saveToUserDefaultsValue:street withKey:kDeliveryStreet];
}

- (void)setHouse:(NSString * __nonnull)house {
    [self saveToUserDefaultsValue:house withKey:kDeliveryHouse];
}

- (void)setCorpus:(NSString * __nonnull)corpus {
    [self saveToUserDefaultsValue:corpus withKey:kDeliveryCorpus];
}

- (void)setApartment:(NSString * __nonnull)apartment {
    [self saveToUserDefaultsValue:apartment withKey:kDeliveryApartment];
}

- (void)saveToUserDefaultsValue:(NSString *)value withKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
