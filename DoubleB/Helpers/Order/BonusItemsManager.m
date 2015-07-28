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

@interface BonusItemsManager ()
@property (weak, nonatomic) OrderCoordinator *parentManager;
@end

@implementation BonusItemsManager

- (instancetype)initWithParentManager:(OrderCoordinator *)parentManager{
    self = [super init];
    if (self) {
        _parentManager = parentManager;
        
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

- (OrderItem *)itemAtIndex:(NSUInteger)index {
    if(index < [self.items count]){
        return self.items[index];
    } else {
        return nil;
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
