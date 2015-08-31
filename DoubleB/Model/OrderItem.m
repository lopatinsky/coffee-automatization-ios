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

@interface OrderItem ()
@property (nonatomic) BOOL valid;
@end

@implementation OrderItem

- (instancetype)initWithPosition:(DBMenuPosition *)position{
    self = [super init];
    
    self.position = position;
    self.valid = YES;
    
    return self;
}

+ (instancetype)orderItemFromDictionary:(NSDictionary *)historyItem{
    OrderItem *item = [[OrderItem alloc] init];
    
    DBMenuPosition *position = [[DBMenu sharedInstance] findPositionWithId:historyItem[@"id"]];
    if(position){
        position = [position copy];
        item.valid = YES;
    } else {
        position = [[DBMenuPosition alloc] initWithHistoryDict:historyItem];
        item.valid = NO;
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
        self.valid = [[aDecoder decodeObjectForKey:@"valid"] boolValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:@(self.count) forKey:@"count"];
    [aCoder encodeObject:@(self.valid) forKey:@"valid"];
}

- (id)copyWithZone:(NSZone *)zone{
    OrderItem *orderItem = [[[self class] allocWithZone:zone] init];
    
    orderItem.position = [self.position copy];
    orderItem.count = self.count;
    
    return orderItem;
}

@end
