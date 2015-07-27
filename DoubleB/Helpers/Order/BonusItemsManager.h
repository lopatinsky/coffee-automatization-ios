//
//  BonusItemsManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerProtocol.h"

@class DBMenuBonusPosition;

@interface BonusItemsManager : NSObject<ManagerProtocol>

/**
 * Bonus items in order
 */
@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, readonly) NSUInteger totalCount;
@property (nonatomic, readonly) double totalPrice;

- (void)addBonusPosition:(DBMenuBonusPosition *)bonusPosition;
- (void)removeBonusPosition:(DBMenuBonusPosition *)bonusPosition;
- (void)removeBonusPositionAtIndex:(NSUInteger)index;

@end
