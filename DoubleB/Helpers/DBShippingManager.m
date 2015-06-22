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

NSString *const kDBDefaultsShippingAddress = @"kDBDefaultsShippingAddress";

NSString *DeliveryManagerDidRecieveSuggestionsNotification = @"DeliveryManagerDidRecieveSuggestionsNotification";

@interface DBShippingManager()

@property (nonatomic, strong) NSArray *addressSuggestions;
//@property (nonatomic, strong) NSTimer *requestSuggestionsTimer;

@end

@implementation DBShippingManager

+ (instancetype)sharedManager {
    static DBShippingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    
    [self fetchAll];
    
    if(_selectedAddress.city.length == 0){
        _selectedAddress.city = [self.arrayOfCities firstObject] ?: @"";
    }
    
    self.addressSuggestions = @[];
    
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
                                      
                                      [[NSNotificationCenter defaultCenter] postNotificationName:DeliveryManagerDidRecieveSuggestionsNotification object:nil];
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
//    
//    if (_address == nil) {
//        _address = address;
//        return;
//    }
//    
//    _selectedAddress[@"address"][@"street"] = _address;
//    if (![_address isEqualToString:address]) {
//        _address = address;
//        if (self.requestSuggestionsTimer) {
//            [self.requestSuggestionsTimer invalidate];
//            self.requestSuggestionsTimer = nil;
//        }
//        self.requestSuggestionsTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(requestSuggestions) userInfo:nil repeats:NO];
//        [self saveToUserDefaultsValue:address withKey:kDeliveryAddress];
//    }
}

- (void)setApartment:(NSString *)apartment {
    _selectedAddress.apartment = apartment ?: @"";
    
    [self synchronize];
}

- (void)setCity:(NSString *)city {
    _selectedAddress.city = city ?: @"";
    
    _selectedAddress.address = @"";
    _selectedAddress.home = @"";
    _selectedAddress.location = nil;
    
    [self synchronize];
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
    
    double lat = [dict[@"coordinates"][@"lat"] doubleValue];
    double lon = [dict[@"coordinates"][@"lon"] doubleValue];
    _location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    
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
    
    return @{@"address": address, @"coordinates": coordinates};
}

- (NSString *)formattedShortAddressString{
    NSString *result = @"";
    
    if(_address.length > 0){
        result = [result stringByAppendingString:_address];
        
        if(_home.length > 0){
            result = [result stringByAppendingString:[NSString stringWithFormat:@", %@", _home]];
        }
    }
    
    return result;
}

- (NSString *)formattedFullAddressString{
    NSString *result = @"";
    if(_address.length > 0){
        result = [result stringByAppendingString:_address];
        
        if(_home.length > 0){
            result = [result stringByAppendingString:[NSString stringWithFormat:@", %@", _home]];
            
            if(_apartment.length > 0){
                result = [result stringByAppendingString:[NSString stringWithFormat:@" - %@", _apartment]];
            }
        }
    }
    
    return result;
}

- (NSString *)formattedWholeAddressString{
    NSString *result = @"";
    if(_city.length > 0){
        result = [result stringByAppendingString:_city];
        if(_address.length > 0){
            result = [result stringByAppendingString:[NSString stringWithFormat:@", %@", _address]];
            
            if(_home.length > 0){
                result = [result stringByAppendingString:[NSString stringWithFormat:@", %@", _home]];
                
                if(_apartment.length > 0){
                    result = [result stringByAppendingString:[NSString stringWithFormat:@" - %@", _apartment]];
                }
            }
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
