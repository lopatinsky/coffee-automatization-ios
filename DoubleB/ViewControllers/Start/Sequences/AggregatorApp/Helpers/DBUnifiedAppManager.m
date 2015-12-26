//
//  DBUnifiedAppManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedAppManager.h"
#import "DBAPIClient.h"
#import "NetworkManager.h"
#import "Venue.h"

#import "DBMenuPosition.h"

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

- (NSArray *)menu {
    return [DBUnifiedAppManager valueForKey:@"menu"] ?: @[];
}

- (NSArray *)venues {
    NSArray *venuesData = [DBUnifiedAppManager valueForKey:@"venues"] ?: @[];
    return [Venue venuesFromDict:venuesData];
}

+ (DBUnifiedCity *)selectedCity {
    NSData *cityData = [DBUnifiedAppManager valueForKey:@"selectedCity"];
    if (![cityData isKindOfClass:[NSData class]])
        cityData = nil;
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:cityData];
}

+ (void)selectCity:(DBUnifiedCity *)city {
    NSData *cityData = [NSKeyedArchiver archivedDataWithRootObject:city];
    [DBUnifiedAppManager setValue:cityData forKey:@"selectedCity"];
    
    if (city) {
        [DBAPIClient sharedClient].cityHeaderEnabled = YES;
    } else {
        [DBAPIClient sharedClient].cityHeaderEnabled = NO;
    }
    
    [[DBUnifiedAppManager sharedInstance] fetchMenu:nil];
    [[DBUnifiedAppManager sharedInstance] fetchVenues:nil];
}

- (void)fetchCities:(void(^)(BOOL success))callback {
    [[DBAPIClient sharedClient] GET:@"proxy/unified_app/cities"
                         parameters:nil
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSMutableArray *cities = [NSMutableArray new];
                                
                                for (NSDictionary *cityDict in responseObject[@"cities"]) {
                                    [cities addObject:[[DBUnifiedCity alloc] initWithResponseDict:cityDict]];
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
                                
                                NSMutableArray *prunedArray = [NSMutableArray new];
                                for (NSDictionary *position in responseObject[@"items"]) {
                                    NSMutableDictionary *_dict = [position mutableCopy];
                                    NSArray *keysForNullValues = [_dict allKeysForObject:[NSNull null]];
                                    [_dict removeObjectsForKeys:keysForNullValues];
                                    [prunedArray addObject:_dict];
                                }
                                
                                [DBUnifiedAppManager setValue:prunedArray forKey:@"menu"];
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

- (void)fetchVenues:(void (^)(BOOL))callback {
    [[DBAPIClient sharedClient] GET:@"proxy/unified_app/venues"
                         parameters:@{@"City-Id": [[DBUnifiedAppManager selectedCity] cityId]}
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSArray *venues = [Venue venuesFromDict:responseObject[@"venues"]];
                                NSMutableArray *venuesDictionaries = [NSMutableArray new];
                                for (Venue *venue in venues) {
                                    [venuesDictionaries addObject:venue.venueDictionary];
                                }
                                [DBUnifiedAppManager setValue:venuesDictionaries forKey:@"venues"];
                                [DBUnifiedAppManager setValue:@(YES) forKey:@"venuesLoaded"];
                                
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
                                
                                NSArray *venues = [Venue venuesFromDict:responseObject[@"venues"]];
                                NSMutableArray *venuesDictionaries = [NSMutableArray new];
                                for (Venue *venue in venues) {
                                    [venuesDictionaries addObject:venue.venueDictionary];
                                }

                                [DBUnifiedAppManager setValue:venues forKey:[NSString stringWithFormat:@"positions_%@", itemId]];
                                
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
