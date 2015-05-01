//
//  PromoManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 11.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OrderItem;

/**
 * Class for manage all info about item promo
 */
@interface DBPromoItem : NSObject
@property (strong, nonatomic) OrderItem *orderItem;

@property (strong, nonatomic) NSArray *errors;
@property (strong, nonatomic) NSArray *promos;
@end



@interface DBPromoManager : NSObject
/**
 * Discount for order synchronized with server
 */
@property (nonatomic, readonly) double discount;

/**
 * Bonuses available for order payment
 */
@property (nonatomic, readonly) double bonuses;
@property (nonatomic) BOOL bonusesActive;


/**
 * Total discount for order (discount + bonuses(if active))
 */
@property (nonatomic, readonly) double totalDiscount;

/**
 * Mark of order validity synchronized with server
 */
@property (nonatomic, readonly) BOOL validOrder;

/**
 * Order errors & promos from server
 */
@property (strong, nonatomic, readonly) NSArray *errors;
@property (strong, nonatomic, readonly) NSArray *promos;


+ (instancetype)sharedManager;


- (void)updateInfo:(void(^)(BOOL success))callback;
- (void)clear;

- (DBPromoItem *)promosForOrderItem:(OrderItem *)item;



// Logic of personal wallet
@property(nonatomic, readonly) NSInteger walletBalance;
- (void)synchronizeWalletInfo:(void(^)(int balance))callback;

@end
