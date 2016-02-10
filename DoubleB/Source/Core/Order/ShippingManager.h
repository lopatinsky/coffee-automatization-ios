//
//  DeliveryManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 09/06/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ManagerProtocol.h"
#import "OrderPartManagerProtocol.h"


typedef NS_ENUM(NSInteger, ShippingManagerChange) {
    ShippingManagerChangeSuggestions = 0,
    ShippingManagerChangeAddress
};

typedef NS_ENUM(NSUInteger, DBAddressStringMode) {
    DBAddressStringModeAutocomplete = 0,
    DBAddressStringModeShort,
    DBAddressStringModeNormal,
    DBAddressStringModeFull
};

typedef NS_ENUM(NSUInteger, DBAddressAttribute) {
    DBAddressAttributeCountry = 0,
    DBAddressAttributeCity,
    DBAddressAttributeStreet,
    DBAddressAttributeHome,
    DBAddressAttributeApartment,
    DBAddressAttributeEntranceNumber,
    DBAddressAttributeComment
};

@interface DBShippingAddress : NSObject
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *home;
@property (nonatomic, strong) NSString *apartment;
@property (nonatomic, strong) NSString *entranceNumber;
@property (nonatomic, strong) NSString *comment;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic) BOOL valid;
@property (nonatomic, strong) NSDictionary *jsonRepresentation;

- (instancetype)initWithDict:(NSDictionary *)dict;

- (NSString *)formattedAddressString:(DBAddressStringMode)mode;
+ (BOOL)required:(DBAddressAttribute)attribute;
@end;


extern NSString *kDBShippingManagerDidRecieveSuggestionsNotification;

@interface ShippingManager : NSObject<ManagerProtocol, OrderPartManagerProtocol>
@property (nonatomic, strong, readonly) DBShippingAddress *selectedAddress;

- (void)setCity:(NSString *)city;
- (void)setStreet:(NSString *)street;
- (void)setHome:(NSString *)home;
- (void)setApartment:(NSString *)apartment;
- (void)setComment:(NSString *)comment;
- (void)setEntranceNumber:(NSString *)entranceNumber;

@property (nonatomic, readonly) BOOL validAddress;

- (void)requestSuggestions;
- (void)requestSuggestions:(void (^)(BOOL success))callback;
- (NSArray *)addressSuggestions;

- (NSArray *)arrayOfCities;
- (BOOL)hasCity:(NSString *)city;

@end

