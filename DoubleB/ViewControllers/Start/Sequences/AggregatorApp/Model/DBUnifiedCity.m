//
//  DBCity.m
//  DoubleB
//
//  Created by Balaban Alexander on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedCity.h"

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