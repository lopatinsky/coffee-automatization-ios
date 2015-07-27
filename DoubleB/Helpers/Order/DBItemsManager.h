//
//  DBItemsManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBItemsManager : NSObject

/**
 * All positions in order
 */
@property (nonatomic, strong) NSMutableArray *items;

/**
 * Total price for order items
 */
@property (nonatomic) double totalPrice;

@property (nonatomic, readonly) NSUInteger totalCount;

@end
