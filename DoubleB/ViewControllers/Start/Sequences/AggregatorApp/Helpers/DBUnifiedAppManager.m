//
//  DBUnifiedAppManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedAppManager.h"
#import "DBAPIClient.h"


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

+ (NSString *)db_managerStorageKey {
    return @"kDBDBUnifiedAppManagerDefaultsInfo";
}

@end
