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

@end
