//
//  DBCitiesManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBCitiesManager.h"
#import "DBAPIClient.h"

@implementation DBUnifiedCity

- (instancetype)initWithResponseDict:(NSDictionary *)dict {
    self = [super init];
    
    self.cityId = [dict getValueForKey:@"id"] ?: @"";
    self.cityName = [dict getValueForKey:@"city"] ?: @"";
    
    return self;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBUnifiedCity alloc] init];
    _cityId = [aDecoder decodeObjectForKey:@"_cityId"];
    _cityName = [aDecoder decodeObjectForKey:@"_cityName"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_cityId forKey:@"_cityId"];
    [aCoder encodeObject:_cityName forKey:@"_cityName"];
}
@end

@implementation DBCitiesManager

- (BOOL)citiesLoaded {
    return [[DBCitiesManager valueForKey:@"citiesLoaded"] boolValue];
}

- (NSArray *)cities {
    return [self cities:nil];
}

- (NSArray *)cities:(NSString *)predicate {
    NSData *citiesData = [DBCitiesManager valueForKey:@"cities"];
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

+ (DBUnifiedCity *)selectedCity {
    NSData *cityData = [DBCitiesManager valueForKey:@"selectedCity"];
    if (![cityData isKindOfClass:[NSData class]])
        cityData = nil;
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:cityData];
}

+ (void)selectCity:(DBUnifiedCity *)city {
    NSData *cityData = [NSKeyedArchiver archivedDataWithRootObject:city];
    [DBCitiesManager setValue:cityData forKey:@"selectedCity"];
    
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
                                    [cities addObject:[[DBUnifiedCity alloc] initWithResponseDict:cityDict]];
                                }
                                
                                if (cities.count == 1) {
                                    [DBCitiesManager selectCity:[cities firstObject]];
                                }
                                
                                // Save cities
                                NSData *citiesData = [NSKeyedArchiver archivedDataWithRootObject:cities];
                                [DBCitiesManager setValue:citiesData forKey:@"cities"];
                                [DBCitiesManager setValue:@(YES) forKey:@"citiesLoaded"];
                                
                                if (callback)
                                    callback(YES);
                            }
                            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"%@", error);
                                
                                if (callback)
                                    callback(NO);
                            }];
}

+ (NSString *)db_managerStorageKey {
    return @"kDBDBCitiesManagerDefaultsInfo";
}

@end
