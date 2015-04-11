//
//  OrderManager.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Order.h"

extern NSString* const kDBDefaultsPaymentType;

@class Venue;
@class OrderItem;
@class DBMenuPosition;

typedef NS_ENUM(NSUInteger, DBBeverageMode) {
    DBBeverageModeTakeaway = 0,
    DBBeverageModeInCafe = 1
};

/**
* Manages order
* Only one order can be managed at a time
*/
@interface OrderManager : NSObject

/**
* All positions in order
*/
@property (nonatomic, strong) NSMutableArray *items;

/**
* Selected venue for order
*/
@property (nonatomic, strong) Venue *venue;

/**
* Selected delivery time
*/
@property (nonatomic, strong) NSNumber *time;

/**
* Selected comment
*/
@property (nonatomic, strong) NSString *comment;

/**
* User's location
*/
@property (nonatomic, strong) CLLocation *location;

/**
* Current order's ID fetched from server
*/
@property (nonatomic, strong) NSString *orderId;

/**
* Selected payment type
*/
@property (nonatomic) PaymentType paymentType;

/**
* Check if current order satisfy all conditions
*/
@property (nonatomic, readonly) BOOL validOrder;

/**
 * Total price for order according to promo info from server
 */
@property (nonatomic) double totalPrice;

/**
 * Total price according only stored prices
 */
@property (nonatomic) double initialTotalPrice;

/**
 * Total price according to promo info(last updated) + price of positions not verified by server
 */
@property (nonatomic) double mixedTotalPrice;

@property (nonatomic, readonly) NSUInteger positionsCount;
@property (nonatomic, readonly) NSUInteger totalCount;
@property (nonatomic, strong) NSArray *globalPromos;
@property (nonatomic, strong) NSArray *globalErrors;

@property (nonatomic) DBBeverageMode beverageMode;

+ (instancetype)sharedManager;

/**
* Register new order on server in order to get orderID
*/
- (void)registerNewOrderWithCompletionHandler:(void(^)(BOOL success, NSString *orderId))completionHandler;

- (NSInteger)addPosition:(DBMenuPosition *)position;

- (NSInteger)increaseOrderItemCountAtIndex:(NSInteger)index;
- (NSInteger)decreaseOrderItemCount:(NSInteger)index;

- (void)purgePositions; //clean
- (void)overridePositions:(NSArray *)items; //clean and add from array

- (OrderItem *)itemAtIndex:(NSUInteger)index;
- (OrderItem *)itemWithPositionId:(NSString *)positionId;
- (void)removePositionAtIndex:(NSUInteger)index;
- (NSUInteger)amountOfOrderPositionAtIndex:(NSInteger)index;

//- (BOOL)shouldGiveDiscount;
//- (int)positionWithDiscount;
- (void)selectIfPossibleDefaultPaymentType;

+ (NSUInteger)totalCountForItems:(NSArray *)items;

@end
