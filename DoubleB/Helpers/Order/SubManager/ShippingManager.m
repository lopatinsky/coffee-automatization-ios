//
//  DeliveryManager.m
//  DoubleB
//
//  Created by Balaban Alexander on 09/06/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfo.h"
#import "OrderCoordinator.h"
#import "DBServerAPI.h"

#import "ShippingManager.h"

NSString *const kDBDefaultsShippingAddress = @"kDBDefaultsShippingAddress";

NSString *kDBShippingManagerDidRecieveSuggestionsNotification = @"kDBShippingManagerDidRecieveSuggestionsNotification";

@interface ShippingManager()
@property (weak, nonatomic) id<OrderParentManagerProtocol> parentManager;

@property (nonatomic, strong) NSArray *addressSuggestions;
//@property (nonatomic, strong) NSTimer *requestSuggestionsTimer;

@end

@implementation ShippingManager

- (instancetype)initWithParentManager:(id<OrderParentManagerProtocol>)parentManager{
    self = [super init];
    if (self) {
        _parentManager = parentManager;
        
        [self fetchAll];
        
        if(_selectedAddress.city.length == 0){
            _selectedAddress.city = [self.arrayOfCities firstObject] ?: @"";
        }
        
        self.addressSuggestions = @[];
    }
    
    return self;
}

- (nonnull NSArray *)arrayOfCities {
    return [[DBCompanyInfo sharedInstance] deliveryCities];
}

- (BOOL)hasCity:(NSString *)city{
    return [self.arrayOfCities containsObject:city];
}

- (BOOL)validAddress{
    return _selectedAddress.valid;
}

- (void)requestSuggestions {
    [self requestSuggestions:nil];
}

- (void)requestSuggestions:(void (^)(BOOL success))callback {
    [DBServerAPI requestAddressSuggestions:@{@"city": _selectedAddress.city, @"street": _selectedAddress.street}
                                  callback:^(BOOL success, NSArray *response) {
                                      NSMutableArray *suggestions = [NSMutableArray new];
                                      for(NSDictionary *suggestionDict in response){
                                          [suggestions addObject:[[DBShippingAddress alloc] initWithDict:suggestionDict]];
                                      }
                                      
                                      self.addressSuggestions = suggestions;
                                      
                                      [self.parentManager manager:self haveChange:ShippingManagerChangeSuggestions];
                                      
                                      if (callback)
                                          callback(success);
                                  }];
}

- (nonnull NSArray *)addressSuggestions {
    return _addressSuggestions;
}


#pragma mark - Setter overrides

- (void)setCity:(NSString *)city {
    _selectedAddress.city = city ?: @"";
    
    _selectedAddress.street = @"";
    _selectedAddress.location = nil;
    
    [self synchronize];
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (void)setStreet:(NSString *)street {
    _selectedAddress.street = street ?: @"";
    
    [self synchronize];
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (void)setHome:(NSString *)home {
    _selectedAddress.home = home ?: @"";
    
    [self synchronize];
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (void)setApartment:(NSString *)apartment {
    _selectedAddress.apartment = apartment ?: @"";
    
    [self synchronize];
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (void)setComment:(NSString *)comment {
    _selectedAddress.comment = comment ?: @"";
    
    [self synchronize];
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (void)setEntranceNumber:(NSString *)entranceNumber {
    _selectedAddress.entranceNumber = entranceNumber ?: @"";
    
    [self synchronize];
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (void)synchronize {
    if(self.selectedAddress){
        [[NSUserDefaults standardUserDefaults] setObject:_selectedAddress.jsonRepresentation forKey:kDBDefaultsShippingAddress];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)fetchAll{
    NSDictionary *addressDict = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsShippingAddress];
    if(addressDict){
        _selectedAddress = [[DBShippingAddress alloc] initWithDict:addressDict];
    } else {
        _selectedAddress = [DBShippingAddress new];
    }
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

#pragma mark - DBManagerProtocol

- (void)flushCache{
    _addressSuggestions = @[];
    _selectedAddress = [DBShippingAddress new];
}

- (void)flushStoredCache{
    [self flushCache];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDBDefaultsShippingAddress];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@implementation DBShippingAddress

- (instancetype)init{
    self = [super init];
    
    _country = @"";
    _city = @"";
    _street = @"";
    _home = @"";
    _apartment = @"";
    _comment = @"";
    _entranceNumber = @"";
    
    _location = nil;
    
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    
    _country = [dict[@"address"] getValueForKey:@"country"] ?: @"";
    _city = [dict[@"address"] getValueForKey:@"city"] ?: @"";
    _street = [dict[@"address"] getValueForKey:@"street"] ?: @"";
    _home = [dict[@"address"] getValueForKey:@"home"] ?: @"";
    _apartment = [dict[@"address"] getValueForKey:@"flat"] ?: @"";
    _entranceNumber = [dict[@"address"] getValueForKey:@"entranceNumber"] ?: @"";
    
    NSDictionary *coordinates = [dict getValueForKey:@"coordinates"];
    if(coordinates){
        double lat = [[coordinates getValueForKey:@"lat"] doubleValue];
        double lon = [[coordinates getValueForKey:@"lon"] doubleValue];
        _location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    }
    
    _comment = [dict getValueForKey:@"comment"] ?: @"";
    
    return self;
}

+ (BOOL)required:(DBAddressAttribute)attribute {
    switch (attribute) {
        case DBAddressAttributeCountry:
            return NO;
            break;
        case DBAddressAttributeCity:
            return YES;
            break;
        case DBAddressAttributeStreet:
            return YES;
            break;
        case DBAddressAttributeHome:
            return YES;
            break;
        case DBAddressAttributeEntranceNumber:{
            if ([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"chaychonatlt"]) {
                return YES;
            } else {
                return NO;
            }
        }
            break;
        case DBAddressAttributeApartment:
            return YES;
            break;
        case DBAddressAttributeComment:
            return NO;
            break;
            
        default:
            break;
    }
}

- (NSDictionary *)jsonRepresentation{
    NSDictionary *coordinates = @{};
    if(_location){
        coordinates = @{@"lat": @(_location.coordinate.latitude),
                        @"lon": @(_location.coordinate.longitude)};
    }
    
    NSDictionary *address = @{@"country": _country ?: @"",
                              @"city": _city ?: @"",
                              @"street": _street ?: @"",
                              @"home": _home ?: @"",
                              @"flat": _apartment ?: @"",
                              @"entranceNumber": _entranceNumber ?: @""};
    
    return @{@"address": address, @"coordinates": coordinates, @"comment": _comment ?: @""};
}

- (NSString *)formattedAddressString:(DBAddressStringMode)mode{
    NSString *result = @"";
    
//    if(mode == DBAddressStringModeAutocomplete){
//        if(_street.length > 0){
//            result = _street;
//            
//            if([result rangeOfString:@","].location == NSNotFound){
//                result = [NSString stringWithFormat:@"%@, ", result];
//            }
//            
//            if(_home.length > 0){
//                result = [NSString stringWithFormat:@"%@%@",result, _home];
//            }
//        }
//    }
    
    if(mode >= DBAddressStringModeShort){
        if(_street.length > 0){
            result =  _street;
            
            if(_home.length > 0){
                result = [NSString stringWithFormat:@"%@, %@",result, _home];
            }
        }
    }
    
    if(mode >= DBAddressStringModeNormal){
        if(result.length > 0 && _apartment.length > 0){
            result = [NSString stringWithFormat:@"%@ - %@", result, _apartment];
        }
    }
    
    if(mode >= DBAddressStringModeFull){
        if(_city.length > 0){
            result = [NSString stringWithFormat:@"%@, %@", _city, result];
        }
    }
    
    return result;
}

- (BOOL)valid{
    BOOL valid = YES;
    
    if ([DBShippingAddress required:DBAddressAttributeCity]){
        valid = valid && _city && _city.length > 0;
    }
    
    if ([DBShippingAddress required:DBAddressAttributeStreet]){
        valid = valid && _street && _street.length > 0;
    }
        
    if ([DBShippingAddress required:DBAddressAttributeHome]){
        valid = valid && _home && _home.length > 0;
    }
        
    if ([DBShippingAddress required:DBAddressAttributeApartment]){
        valid = valid && _apartment && _apartment.length > 0;
    }
    
    if ([DBShippingAddress required:DBAddressAttributeEntranceNumber]){
        valid = valid && _entranceNumber && _entranceNumber.length > 0;
    }
    
    return valid;
}

@end
