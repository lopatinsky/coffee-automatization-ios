//
//  DBUnifiedAppManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedAppManager.h"
#import "DBAPIClient.h"

#import "DBMenuPosition.h"

@implementation DBCity

- (instancetype)initWithResponseDict:(NSDictionary *)dict {
    self = [super init];
    
    self.cityId = [dict getValueForKey:@"id"] ?: @"";
    self.cityName = [dict getValueForKey:@"city"] ?: @"";
    
    return self;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBCity alloc] init];
    if(self != nil){
        _cityId = [aDecoder decodeObjectForKey:@"_cityId"];
        _cityName = [aDecoder decodeObjectForKey:@"_cityName"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_cityId forKey:@"_cityId"];
    [aCoder encodeObject:_cityName forKey:@"_cityName"];
}
@end


@implementation DBUnifiedAppManager

- (BOOL)citiesLoaded {
    return [[DBUnifiedAppManager valueForKey:@"citiesLoaded"] boolValue];
}

- (NSArray *)allPositions {
    NSData *menuData = [DBUnifiedAppManager valueForKey:@"menu"];
    if (menuData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:menuData];
    } else {
        return @[];
    }
}

- (NSDictionary *)positionsForItem:(NSNumber *)stringId {
    NSData *positionsData = [DBUnifiedAppManager valueForKey:[NSString stringWithFormat:@"positions_%@", stringId]];
    if (positionsData) {
        NSArray *positionsInfo = [NSKeyedUnarchiver unarchiveObjectWithData:positionsData];
        
        NSMutableDictionary *result = [NSMutableDictionary new];
        for (NSDictionary *positionInfo in positionsInfo) {
            NSString *companyId = positionInfo[@"company"][@"name"];
            
            if ([result objectForKey:companyId]) {
                NSMutableArray *items = result[companyId][@"items"];
                for (NSDictionary *item in positionInfo[@"items"]) {
                    [items addObject:@{@"item": [[DBMenuPosition alloc] initWithResponseDictionary:item],
                                       @"venue_info": positionInfo[@"venue_info"]}];
                }
            } else {
                NSMutableDictionary *newCompany = [NSMutableDictionary new];
                NSMutableArray *items = [NSMutableArray new];
                newCompany[@"company"] = positionInfo[@"company"];
                for (NSDictionary *item in positionInfo[@"items"]) {
                    [items addObject:@{@"item": [[DBMenuPosition alloc] initWithResponseDictionary:item],
                                       @"venue_info": positionInfo[@"venue_info"]}];
                }
                newCompany[@"items"] = items;
                result[companyId] = newCompany;
            }
        }
        return result;
    } else {
        return @{};
    }
}

- (NSArray *)cities {
    return [self cities:nil];
}

- (NSArray *)cities:(NSString *)predicate {
    NSData *citiesData = [DBUnifiedAppManager valueForKey:@"cities"];
    if (![citiesData isKindOfClass:[NSData class]])
        citiesData = nil;
    
     NSArray *cities = [NSKeyedUnarchiver unarchiveObjectWithData:citiesData];
    if (predicate && predicate.length > 0) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"cityName CONTAINS[c] %@", predicate];
        return [cities filteredArrayUsingPredicate:pred];
    } else {
        return cities;
    }
}

+ (DBCity *)selectedCity {
    NSData *cityData = [DBUnifiedAppManager valueForKey:@"selectedCity"];
    if (![cityData isKindOfClass:[NSData class]])
        cityData = nil;
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:cityData];
}

+ (void)selectCity:(DBCity *)city {
    NSData *cityData = [NSKeyedArchiver archivedDataWithRootObject:city];
    [DBUnifiedAppManager setValue:cityData forKey:@"selectedCity"];
    
    if (city) {
        [DBAPIClient sharedClient].cityHeaderEnabled = YES;
    } else {
        [DBAPIClient sharedClient].cityHeaderEnabled = NO;
    }
}

- (void)fetchCities:(void(^)(BOOL success))callback {
    [[DBAPIClient sharedClient] GET:@"proxy/unified_app/cities"
                         parameters:nil
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSMutableArray *cities = [NSMutableArray new];
                                
                                for (NSDictionary *cityDict in responseObject[@"cities"]) {
                                    [cities addObject:[[DBCity alloc] initWithResponseDict:cityDict]];
                                }
                                
                                if (cities.count == 1) {
                                    [DBUnifiedAppManager selectCity:[cities firstObject]];
                                }
                                
                                // Save cities
                                NSData *citiesData = [NSKeyedArchiver archivedDataWithRootObject:cities];
                                [DBUnifiedAppManager setValue:citiesData forKey:@"cities"];
                                [DBUnifiedAppManager setValue:@(YES) forKey:@"citiesLoaded"];
                                
                                if (callback)
                                    callback(YES);
                            }
                            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"%@", error);
                                
                                if (callback)
                                    callback(NO);
                            }];
}

- (void)fetchMenu:(void (^)(BOOL))callback {
    [[DBAPIClient sharedClient] GET:@"proxy/unified_app/menu"
                         parameters:@{}
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSLog(@"%@", responseObject);
                                NSData *menuData = [NSKeyedArchiver archivedDataWithRootObject:responseObject[@"items"]];
                                [DBUnifiedAppManager setValue:menuData forKey:@"menu"];
                                [DBUnifiedAppManager setValue:@(YES) forKey:@"menuLoaded"];
                                
                                if (callback) {
                                    callback(YES);
                                }
                            }
                            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"%@", error);
                                
                                if (callback) {
                                    callback(NO);
                                }
                            }];
}

- (void)fetchPositionsWithId:(NSNumber *)itemId withCallback:(void (^)(BOOL))callback {
    [[DBAPIClient sharedClient] GET:[NSString stringWithFormat:@"proxy/unified_app/product?product_id=%@", itemId]
                         parameters:@{}
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSLog(@"%@", responseObject);
                                NSData *positionsData = [NSKeyedArchiver archivedDataWithRootObject:responseObject[@"venues"]];
                                [DBUnifiedAppManager setValue:positionsData forKey:[NSString stringWithFormat:@"positions_%@", itemId]];
                                
                                if (callback) {
                                    callback(YES);
                                }
                            }
                            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"%@", error);
                                
                                if (callback) {
                                    callback(NO);
                                }
                            }];
}

+ (NSString *)db_managerStorageKey {
    return @"kDBDBUnifiedAppManagerDefaultsInfo";
}

@end
