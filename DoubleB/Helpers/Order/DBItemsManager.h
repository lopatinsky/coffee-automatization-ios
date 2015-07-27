//
//  DBItemsManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManagerProtocol.h"

@class DBMenuPosition;
@class OrderItem;

@interface DBItemsManager : NSObject<DBManagerProtocol>

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

// Return index of items that was merged into current item
- (NSInteger)replaceOrderItem:(OrderItem *)item withPosition:(DBMenuPosition *)position;

- (NSInteger)increaseOrderItemCountAtIndex:(NSInteger)index;
- (NSInteger)decreaseOrderItemCountAtIndex:(NSInteger)index;
- (void)removeOrderItemAtIndex:(NSInteger)index;

@end
