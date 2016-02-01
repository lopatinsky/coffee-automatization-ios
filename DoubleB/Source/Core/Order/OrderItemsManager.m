//
//  DBItemsManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "OrderItemsManager.h"
#import "DBSubscriptionManager.h"

#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "OrderItem.h"
#import "OrderCoordinator.h"

NSString *const kDBItemsManagerNewTotalPriceNotification = @"kDBItemsManagerNewTotalPriceNotification";

@interface ItemsManager ()

@property (weak, nonatomic) id<OrderParentManagerProtocol> parentManager;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ItemsManager

- (instancetype)initWithParentManager:(id<OrderParentManagerProtocol>)parentManager{
    self = [self init];
    if (self) {
        _parentManager = parentManager;
        
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _items = [NSMutableArray new];
        [self reloadTotal];
    }
    return self;
}

- (NSArray *)positionIdsForSubscribers {
    NSArray *positions = [[[DBSubscriptionManager sharedInstance] subscriptionCategory] positions];
    NSMutableArray *positionIds = [NSMutableArray new];
    for (DBMenuPosition *position in positions) {
        [positionIds addObject:[position positionId]];
    }
    return positionIds;
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
    
    NSArray *positionIds = [self positionIdsForSubscribers];
    if ([positionIds containsObject:position.positionId]) {
        [[DBSubscriptionManager sharedInstance] incrementNumberOfCupsInOrder:position.positionId];
    }
    
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
    
    NSArray *positionIds = [self positionIdsForSubscribers];
    if ([positionIds containsObject:orderItem.position.positionId]) {
        [[DBSubscriptionManager sharedInstance] incrementNumberOfCupsInOrder:orderItem.position.positionId];
    }
    
    [self reloadTotal];
    
    return orderItem.count;
    
}

- (NSInteger)decreaseOrderItemCountAtIndex:(NSInteger)index {
    if(index < 0 || index >= [self.items count])
        return 0;
    
    OrderItem *orderItem = self.items[index];
    orderItem.count--;
    
    NSArray *positionIds = [self positionIdsForSubscribers];
    if ([positionIds containsObject:orderItem.position.positionId]) {
        [[DBSubscriptionManager sharedInstance] decrementNumberOfCupsInOrder];
    }
    
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
    [_parentManager manager:self haveChange:ItemsManagerChangeTotalCount];
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

- (void)overrideItems:(NSArray *)items {
    [super overrideItems:items];
    self.items = [NSMutableArray array];
    
    for (OrderItem *item in items) {
        if(item.valid){
            OrderItem *newItem = [item copy];
            [self.items addObject:newItem];
        }
    }
    
    [self reloadTotal];
}

- (NSInteger)addPosition:(DBMenuPosition *)position {
    [position selectAllRequiredModifiers];
    
    [[DBMenu sharedInstance] syncWithPosition:position];
    
    return [super addPosition:position];
}

@end

@implementation OrderBonusItemsManager
@end

@implementation OrderGiftItemsManager

- (void)overrideItems:(NSArray *)items {
    [super overrideItems:items];
    self.items = [NSMutableArray array];
    
    for (OrderItem *item in items) {
        OrderItem *newItem = [item copy];
        [self.items addObject:newItem];
    }
    
    [self reloadTotal];
}

- (void)synchronizeItemsWithPositions:(NSArray *)positions{
    [self flushCache];
    
    for(DBMenuPosition *position in positions){
        [self addPosition:position];
    }
}

@end
