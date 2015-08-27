//
//  DBItemsManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "OrderItemsManager.h"
#import "DBMenuPosition.h"
#import "OrderItem.h"
#import "OrderCoordinator.h"

NSString *const kDBItemsManagerNewTotalPriceNotification = @"kDBItemsManagerNewTotalPriceNotification";

@interface ItemsManager ()
@property (weak, nonatomic) OrderCoordinator *parentManager;
@end

@implementation ItemsManager

- (instancetype)initWithParentManager:(OrderCoordinator *)parentManager{
    self = [super init];
    if (self) {
        _parentManager = parentManager;
        _items = [NSMutableArray new];
        [self reloadTotal];
    }
    
    return self;
}

- (OrderItem *)createItemWithPosition:(DBMenuPosition *)position{
    OrderItem *item = [[OrderItem alloc] initWithPosition:position];
    item.count = 1;
    
    return item;
}

- (NSInteger)addPosition:(DBMenuPosition *)position {
    // Main logic
    DBMenuPosition *copyPosition = [position copy];
    OrderItem *itemWithSamePosition;
    
    for(OrderItem *item in self.items){
        if([item.position isEqual:copyPosition]){
            itemWithSamePosition = item;
            break;
        }
    }
    
    NSInteger currentCount;
    if (!itemWithSamePosition) {
        [self.items addObject:[self createItemWithPosition:copyPosition]];
        currentCount = 1;
    } else {
        itemWithSamePosition.count ++;
        currentCount = itemWithSamePosition.count;
    }
    
    [self reloadTotal];
    
    return currentCount;
}

- (NSInteger)increaseOrderItemCountAtIndex:(NSInteger)index{
    if(index < 0 || index >= [self.items count])
        return 0;
    
    OrderItem *orderItem = self.items[index];
    orderItem.count++;
    
    [self reloadTotal];
    
    return orderItem.count;
    
}

- (NSInteger)decreaseOrderItemCountAtIndex:(NSInteger)index {
    if(index < 0 || index >= [self.items count])
        return 0;
    
    OrderItem *orderItem = self.items[index];
    orderItem.count--;
    if(orderItem.count < 1){
        [self.items removeObject:orderItem];
    }
    
    [self reloadTotal];
    
    return orderItem.count;
}

- (void)removeOrderItemAtIndex:(NSInteger)index{
    [self.items removeObjectAtIndex:index];
    
    [self reloadTotal];
}

- (NSInteger)replaceOrderItem:(OrderItem *)item withPosition:(DBMenuPosition *)position{
    DBMenuPosition *copyPosition = [position copy];
    item.position = copyPosition;
    
    NSInteger index = -1;
    for(OrderItem *orderItem in self.items){
        if(orderItem != item && [orderItem.position isEqual:copyPosition]){
            item.count += orderItem.count;
            index = [self.items indexOfObject:orderItem];
            [self.items removeObject:orderItem];
            
            break;
        }
    }
    
    [self reloadTotal];
    
    return index;
}

- (void)overrideItems:(NSArray *)items {
    _items = [NSMutableArray array];
    
    for (OrderItem *item in items) {
        if(item.valid){
            OrderItem *newItem = [item copy];
            [self.items addObject:newItem];
        }
    }
    
    [self reloadTotal];
}


- (OrderItem *)itemAtIndex:(NSUInteger)index {
    if(index < [self.items count]){
        return self.items[index];
    } else {
        return nil;
    }
}

- (OrderItem *)itemWithPositionId:(NSString *)positionId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"position.positionId == %@", positionId];
    OrderItem *item =[[self.items filteredArrayUsingPredicate:predicate] firstObject];
    
    return item;
}

- (OrderItem *)itemWithTemplatePosition:(DBMenuPosition *)templatePosition{
    OrderItem *result;
    for(OrderItem *item in self.items){
        if([item.position isEqual:templatePosition]){
            result = item;
            break;
        }
    }
    
    return result;
}

- (void)reloadTotal{
    [_parentManager manager:self haveChange:ItemsManagerChangeTotalPrice];
}

- (double)totalPrice{
    double total = 0;
    for (OrderItem *item in self.items) {
        total += item.totalPrice;
    }
    
    return total;
}

- (NSUInteger)totalCount {
    NSUInteger count = 0;
    for (OrderItem *item in self.items) {
        count += item.count;
    }
    return count;
}

#pragma mark - DBManagerProtocol

- (void)flushCache{
    _items = [NSMutableArray new];
    [self reloadTotal];
}

- (void)flushStoredCache{
    [self flushCache];
}

@end


@implementation OrderItemsManager
@end

@implementation OrderBonusItemsManager
@end

@implementation OrderGiftItemsManager

- (void)synchronizeItemsWithPositions:(NSArray *)positions{
    [self flushCache];
    
    for(DBMenuPosition *position in positions){
        [self addPosition:position];
    }
}

@end
