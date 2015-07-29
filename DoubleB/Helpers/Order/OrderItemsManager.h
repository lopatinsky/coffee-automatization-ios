//
//  DBItemsManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerProtocol.h"
#import "OrderPartManagerProtocol.h"

@class DBMenuPosition;
@class OrderItem;

typedef NS_ENUM(NSInteger, ItemsManagerChange) {
    ItemsManagerChangeTotalPrice = 0,
    ItemsManagerChangeTotalCount
};

@interface ItemsManager : NSObject<ManagerProtocol, OrderPartManagerProtocol>

/**
 * All positions in order
 */
@property (nonatomic, strong, readonly) NSMutableArray *items;

/**
 * Total price for order items
 */
@property (nonatomic, readonly) double totalPrice;

/**
 * Total count of order items
 */
@property (nonatomic, readonly) NSUInteger totalCount;


- (NSInteger)addPosition:(DBMenuPosition *)position;

- (NSInteger)increaseOrderItemCountAtIndex:(NSInteger)index;
- (NSInteger)decreaseOrderItemCountAtIndex:(NSInteger)index;
- (void)removeOrderItemAtIndex:(NSInteger)index;

- (OrderItem *)itemAtIndex:(NSUInteger)index;
- (OrderItem *)itemWithPositionId:(NSString *)positionId;
- (OrderItem *)itemWithTemplatePosition:(DBMenuPosition *)templatePosition;

/**
 * Replace list of items with new list
 */
- (void)overrideItems:(NSArray *)items;

/**
 * Replace item with other position
 * Return index of items that was merged into current item
 */
- (NSInteger)replaceOrderItem:(OrderItem *)item withPosition:(DBMenuPosition *)position;

@end


// Manager for regular order items
@interface OrderItemsManager : ItemsManager
@end

// Manager for bonus order items
@interface OrderBonusItemsManager : ItemsManager
@end

// Manager for gift order items
@interface OrderGiftItemsManager : ItemsManager
@end
