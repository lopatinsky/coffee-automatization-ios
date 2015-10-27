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

- (BOOL)validAddress{
    return _selectedAddress.valid;
}

- (void)requestSuggestions {
    // request suggestions from backend and push notification about it
//    [self.requestSuggestionsTimer invalidate];
//    self.requestSuggestionsTimer = nil;
    [DBServerAPI requestAddressSuggestions:@{@"city": _selectedAddress.city, @"street": _selectedAddress.address}
                                  callback:^(BOOL success, NSArray *response) {
                                      NSMutableArray *suggestions = [NSMutableArray new];
                                      for(NSDictionary *suggestionDict in response){
                                          [suggestions addObject:[[DBShippingAddress alloc] initWithDict:suggestionDict]];
                                      }
                                      
                                      self.addressSuggestions = suggestions;
                                      
                                      [self.parentManager manager:self haveChange:ShippingManagerChangeSuggestions];
                                  }];
}

- (nonnull NSArray *)addressSuggestions {
    return _addressSuggestions;
}

- (void)selectSuggestion:(DBShippingAddress *)suggestion{
    _selectedAddress.address = suggestion.address;
    _selectedAddress.home = suggestion.home;
    _selectedAddress.location = suggestion.location;
    
    [self synchronize];
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (BOOL)hasCity:(NSString *)city{
    return [self.arrayOfCities containsObject:city];
}


#pragma mark - Setter overrides
- (void)setAddress:(NSString *)address {
    _selectedAddress.address = address ?: @"";
    _selectedAddress.home = @"";
    _selectedAddress.location = nil;
    
    [self synchronize];

    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (void)setApartment:(NSString *)apartment {
    _selectedAddress.apartment = apartment ?: @"";
    
    [self synchronize];
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (void)setCity:(NSString *)city {
    _selectedAddress.city = city ?: @"";
    
    _selectedAddress.address = @"";
    _selectedAddress.home = @"";
    _selectedAddress.location = nil;
    
    [self synchronize];
    
    [self.parentManager manager:self haveChange:ShippingManagerChangeAddress];
}

- (void)setComment:(NSString *)comment {
    _selectedAddress.comment = comment ?: @"";
    
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
    _address = @"";
    _home = @"";
    _apartment = @"";
    _comment = @"";
    
    _location = nil;
    
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    
    _country = [dict[@"address"] getValueForKey:@"country"] ?: @"";
    _city = [dict[@"address"] getValueForKey:@"city"] ?: @"";
    _address = [dict[@"address"] getValueForKey:@"street"] ?: @"";
    _home = [dict[@"address"] getValueForKey:@"home"] ?: @"";
    _apartment = [dict[@"address"] getValueForKey:@"flat"] ?: @"";
    
    NSDictionary *coordinates = [dict getValueForKey:@"coordinates"];
    if(coordinates){
        double lat = [[coordinates getValueForKey:@"lat"] doubleValue];
        double lon = [[coordinates getValueForKey:@"lon"] doubleValue];
        _location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    }
    
    _comment = [dict getValueForKey:@"comment"] ?: @"";
    
    return self;
}

- (NSDictionary *)jsonRepresentation{
    NSDictionary *coordinates = @{};
    if(_location){
        coordinates = @{@"lat": @(_location.coordinate.latitude),
                        @"lon": @(_location.coordinate.longitude)};
    }
    
    NSDictionary *address = @{@"country": _country ?: @"",
                              @"city": _city ?: @"",
                              @"street": _address ?: @"",
                              @"home": _home ?: @"",
                              @"flat": _apartment ?: @""};
    
    return @{@"address": address, @"coordinates": coordinates, @"comment": _comment ?: @""};
}

- (NSString *)formattedAddressString:(DBAddressStringMode)mode{
    NSString *result = @"";
    
    if(mode == DBAddressStringModeAutocomplete){
        if(_address.length > 0){
            result = _address;
            
            if([result rangeOfString:@","].location == NSNotFound){
                result = [NSString stringWithFormat:@"%@, ", result];
            }
            
            if(_home.length > 0){
                result = [NSString stringWithFormat:@"%@%@",result, _home];
            }
        }
    }
        
    if(mode >= DBAddressStringModeShort){
        if(_address.length > 0){
            result =  _address;
            
            if(_home.length > 0){
                result = [NSString stringWithFormat:@"%@, %@",result, _home];
            }
        }
    }
    
    if(mode >= DBAddressStringModeNormal){
        if(_home.length > 0 && _apartment.length > 0){
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
    valid = valid && _city && _city.length > 0;
    valid = valid && _address && _address.length > 0;
    valid = valid && _apartment && _apartment.length > 0;
    
    return valid;
}

@end
