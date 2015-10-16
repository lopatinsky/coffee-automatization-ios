//
//  DBSubscriptionVariant.m
//  DoubleB
//
//  Created by Balaban Alexander on 16/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBSubscriptionVariant.h"

@implementation DBSubscriptionVariant

- (instancetype)initWithResponseDict:(NSDictionary *)dict {
    self = [super init];
    
    self.variantId = [dict getValueForKey:@"id"] ?: @"";
    self.name = [dict getValueForKey:@"title"] ?: @"";
    self.variantDescription = [dict getValueForKey:@"description"] ?: @"";
    self.count = [[dict getValueForKey:@"amount"] intValue];
    self.price = [[dict getValueForKey:@"price"] doubleValue];
    self.period = [[dict getValueForKey:@"days"] intValue];
    
    return self;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[DBSubscriptionVariant alloc] init];
    if(self != nil){
        _variantId = [aDecoder decodeObjectForKey:@"_variantId"];
        _name = [aDecoder decodeObjectForKey:@"_name"];
        _variantDescription = [aDecoder decodeObjectForKey:@"_variantDescription"];
        _count = [[aDecoder decodeObjectForKey:@"_count"] integerValue];
        _price = [[aDecoder decodeObjectForKey:@"_price"] doubleValue];
        _period = [[aDecoder decodeObjectForKey:@"_period"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_variantId forKey:@"_variantId"];
    [aCoder encodeObject:_name forKey:@"_name"];
    [aCoder encodeObject:_variantDescription forKey:@"_variantDescription"];
    [aCoder encodeObject:@(_count) forKey:@"_count"];
    [aCoder encodeObject:@(_price) forKey:@"_price"];
    [aCoder encodeObject:@(_period) forKey:@"_period"];
}

@end
