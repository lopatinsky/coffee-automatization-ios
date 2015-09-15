//
//  OrderItem.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "OrderItem.h"
#import "DBMenuPosition.h"
#import "DBMenu.h"

@implementation OrderItem

- (instancetype)initWithPosition:(DBMenuPosition *)position{
    self = [super init];
    
    self.position = position;
    
    return self;
}

+ (instancetype)orderItemFromResponceDict:(NSDictionary *)dict{
    OrderItem *item = [[OrderItem alloc] init];
    
    DBMenuPosition *position = [[DBMenu sharedInstance] findPositionWithId:dict[@"id"]];
    if(position){
        position = [position copy];
    } else {
        position = [[DBMenuPosition alloc] initWithHistoryDict:dict];
    }
    
    for(NSDictionary *modifier in dict[@"group_modifiers"]){
        [position selectItem:modifier[@"choice"] forGroupModifier:modifier[@"id"]];
    }
    
    for(NSDictionary *modifier in dict[@"single_modifiers"]){
        [position addSingleModifier:modifier[@"id"] count:[modifier[@"quantity"] integerValue]];
    }
    
    item.position = position;
    
    item.count = [dict[@"quantity"] integerValue];
    
    return item;
}

- (double)totalPrice{
    return self.position.actualPrice * self.count;
}

- (BOOL)valid {
    DBMenuPosition *position = [[DBMenu sharedInstance] findPositionWithId:self.position.positionId];
    
    return position != nil;
}


#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[OrderItem alloc] init];
    if(self != nil){
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.count = [[aDecoder decodeObjectForKey:@"count"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:@(self.count) forKey:@"count"];
}

- (id)copyWithZone:(NSZone *)zone{
    OrderItem *orderItem = [[[self class] allocWithZone:zone] init];
    
    orderItem.position = [self.position copy];
    orderItem.count = self.count;
    
    return orderItem;
}

@end
