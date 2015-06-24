//
//  DBMenuGift.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBMenuBonusPosition.h"

@implementation DBMenuBonusPosition

- (instancetype)initWithResponseDictionary:(NSDictionary *)positionDictionary{
    self = [super initWithResponseDictionary:positionDictionary];
    
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    DBMenuBonusPosition *copyPosition = [super copyWithZone:zone];
    copyPosition.pointsPrice = self.pointsPrice;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if(self){
        _pointsPrice = [[aDecoder decodeObjectForKey:@"pointsPrice"] doubleValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:@(self.pointsPrice) forKey:@"pointsPrice"];
}

@end
