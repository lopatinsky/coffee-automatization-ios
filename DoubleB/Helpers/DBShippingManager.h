//
//  DeliveryManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 09/06/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *DeliveryManagerDidRecieveSuggestionsNotification;

@interface DBShippingAddress : NSObject
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *apartment;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *home;

@property (nonatomic) BOOL valid;
@property (nonatomic, strong) NSString * formattedFullAddressString;
@property (nonatomic, strong) NSString * formattedShortAddressString;
@property (nonatomic, strong) NSDictionary *jsonRepresentation;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)clear;
@end;

@interface DBShippingManager : NSObject


@property (nonatomic, strong, readonly) DBShippingAddress *selectedAddress;
- (void)setAddress:(NSString *)address;
- (void)setApartment:(NSString *)apartment;
- (void)setCity:(NSString *)city;

@property (nonatomic, readonly) BOOL validAddress;

+ (instancetype)sharedManager;

- (void)requestSuggestions;
- (NSArray *)addressSuggestions;
- (void)selectSuggestion:(DBShippingAddress *)suggestion;

- (NSArray *)arrayOfCities;

- (BOOL)hasCity:(NSString *)city;

@end

