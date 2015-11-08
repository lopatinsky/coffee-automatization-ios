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
    
    self.cityId = [dict getValueForKey:@""] ?: @"";
    self.cityName = [dict getValueForKey:@""] ?: @"";
    
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

- (NSArray *)cities:(NSString *)predicate {
    NSData *citiesData = [DBUnifiedAppManager valueForKey:@"cities"];
    if (![citiesData isKindOfClass:[NSData class]])
        citiesData = nil;
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:citiesData];
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

+ (NSString *)db_managerStorageKey {
    return @"kDBDBUnifiedAppManagerDefaultsInfo";
}

@end
