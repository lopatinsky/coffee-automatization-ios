//
//  OrderItem.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "OrderItem.h"
#import "DBMenuPosition.h"
#import "DBMenuBonusPosition.h"
#import "DBMenu.h"

@implementation OrderItem

- (instancetype)initWithPosition:(DBMenuPosition *)position{
    self = [super init];
    self.position = position;
    
    return self;
}

+ (instancetype)orderItemFromHistoryDictionary:(NSDictionary *)historyItem bonus:(BOOL)bonus{
    OrderItem *item = [[OrderItem alloc] init];
    
    DBMenuPosition *position;
    if(bonus){
        position = [[DBMenuBonusPosition alloc] initWithResponseDictionary:historyItem];
    } else {
        DBMenuPosition *menuPosition = [[DBMenu sharedInstance] findPositionWithId:historyItem[@"id"]];
        if(menuPosition){
            position = [menuPosition copy];
        }
    }
    
    
    for(NSDictionary *modifier in historyItem[@"group_modifiers"]){
        [position selectItem:modifier[@"choice"] forGroupModifier:modifier[@"id"]];
    }
    
    for(NSDictionary *modifier in historyItem[@"single_modifiers"]){
        [position addSingleModifier:modifier[@"id"] count:[modifier[@"quantity"] integerValue]];
    }
    
    item.position = position;
    
    item.count = [historyItem[@"quantity"] integerValue];
    
    return item;
}

- (double)totalPrice{
    return self.position.actualPrice * self.count;
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
