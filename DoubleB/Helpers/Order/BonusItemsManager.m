//
//  BonusItemsManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "BonusItemsManager.h"
#import "OrderItem.h"
#import "DBMenuBonusPosition.h"

@implementation BonusItemsManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static BonusItemsManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
    }
    return self;
}

- (void)addBonusPosition:(DBMenuBonusPosition *)bonusPosition{
    OrderItem *itemWithSamePosition;
    
    for (OrderItem *item in self.items) {
        if([item.position isEqual:bonusPosition]) {
            itemWithSamePosition = item;
            break;
        }
    }
    
    if (!itemWithSamePosition) {
        itemWithSamePosition = [[OrderItem alloc] initWithPosition:[bonusPosition copy]];
        itemWithSamePosition.count = 1;
        [self.items addObject:itemWithSamePosition];
    } else {
        itemWithSamePosition.count ++;
    }
}

- (void)removeBonusPosition:(DBMenuBonusPosition *)bonusPosition{
    OrderItem *item;
    
    for(OrderItem *orderItem in self.items){
        if([orderItem.position isEqual:bonusPosition]){
            item = orderItem;
            break;
        }
    }
    [self.items removeObject:item];
}

- (void)removeBonusPositionAtIndex:(NSUInteger)index{
    if (index < [self.items count]){
        [self.items removeObjectAtIndex:index];
    }
}

- (NSUInteger)totalCount{
    NSUInteger count = 0;
    for (OrderItem *item in self.items) {
        count += item.count;
    }
    return count;
}

- (double)totalPrice{
    double total = 0;
    for (OrderItem *bonusItem in self.items){
        DBMenuBonusPosition *bonusPosition = (DBMenuBonusPosition *)bonusItem.position;
        total += bonusPosition.pointsPrice * bonusItem.count;
    }
    
    return total;
}

#pragma mark - DBManagerProtocol

- (void)flushCache{
    _items = [NSMutableArray new];
}

- (void)flushStoredCache{
    [self flushCache];
}

@end
