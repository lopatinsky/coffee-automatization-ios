//
//  BonusItemsManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerProtocol.h"
#import "OrderPartManagerProtocol.h"

@class DBMenuBonusPosition;
@class OrderItem;

@interface BonusItemsManager : NSObject<ManagerProtocol, OrderPartManagerProtocol>

/**
 * Bonus items in order
 */
@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, readonly) NSUInteger totalCount;
@property (nonatomic, readonly) double totalPrice;

- (void)addBonusPosition:(DBMenuBonusPosition *)bonusPosition;
- (void)removeBonusPosition:(DBMenuBonusPosition *)bonusPosition;
- (void)removeBonusPositionAtIndex:(NSUInteger)index;

- (OrderItem *)itemAtIndex:(NSUInteger)index;

@end
