//
//  DBItemsManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBItemsManager.h"

@implementation DBItemsManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBItemsManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
        _totalPrice = 0;
        _totalCount = 0;
    }
    return self;
}

- (void)overridePositions:(NSArray *)items {
    self.items = [NSMutableArray array];
    
    for (OrderItem *item in items) {
        OrderItem *newItem = [item copy];
        [self.items addObject:newItem];
    }
    
    [self reloadTotal];
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
        itemWithSamePosition = [[OrderItem alloc] initWithPosition:copyPosition];
        itemWithSamePosition.count = 1;
        [self.items addObject:itemWithSamePosition];
        currentCount = 1;
    } else {
        itemWithSamePosition.count ++;
        currentCount = itemWithSamePosition.count;
    }
    
    [self reloadTotal];
    
    return currentCount;
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

- (NSUInteger)totalCount {
    return [self.items count];
}

#pragma mark - DBManagerProtocol

- (void)flushCache{
    _items = [NSMutableArray new];
}

- (void)flushStoredCache{
    [self flushCache];
}


@end
