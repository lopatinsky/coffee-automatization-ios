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
@class DBMenuBonusPosition;
@class DBDeliverySettings;


/**
* Manages order
* Only one order can be managed at a time
*/
@interface OrderManager : NSObject

/**
* Selected venue for order(if not shipping)
*/
@property (nonatomic, strong) Venue *venue;


/**
* Selected comment
*/
@property (nonatomic, strong) NSString *comment;

/**
* User's location
*/
@property (nonatomic, strong) CLLocation *location;

/**
* Selected payment type
*/
@property (nonatomic) PaymentType paymentType;

/**
* Check if current order satisfy all conditions
*/
@property (nonatomic, readonly) BOOL validOrder;

/**
 * Bonus positions in order
 */
@property (nonatomic, strong) NSMutableArray *bonusPositions;

@property (nonatomic, readonly) NSUInteger bonusPositionsCount;
@property (nonatomic, readonly) double totalBonusPositionsPrice;

+ (instancetype)sharedManager;

- (void)reloadTotal;

- (void)purgePositions; //clean
- (void)overridePositions:(NSArray *)items; //clean and add from array

- (void)addBonusPosition:(DBMenuPosition *)bonusPosition;
- (void)removeBonusPosition:(DBMenuPosition *)bonusPosition;
- (void)removeBonusPositionAtIndex:(NSUInteger)index;

- (OrderItem *)itemAtIndex:(NSUInteger)index;
- (OrderItem *)itemWithPositionId:(NSString *)positionId;
- (OrderItem *)itemWithTemplatePosition:(DBMenuPosition *)templatePosition;
- (NSUInteger)amountOfOrderPositionAtIndex:(NSInteger)index;

- (void)selectIfPossibleDefaultPaymentType;

+ (NSUInteger)totalCountForItems:(NSArray *)items;

@end

@interface DBDeliverySettings : NSObject

+ (instancetype)sharedInstance;

/**
 * Selected type of delivery
 */
@property (strong, nonatomic, readonly) DBDeliveryType *deliveryType;

/**
 * Only use when switch between inRestaurant and takeaway;
 */
- (void)selectDeliveryType:(DBDeliveryType *)type;

/**
 * Only use when switch between shipping and not shipping;
 */
- (void)selectShipping;
- (void)selectTakeout;

#pragma mark - Time management

/**
 * Selected time variant from slots
 */
@property (nonatomic, strong) DBTimeSlot *selectedTimeSlot;

/**
 * Selected delivery time
 */
@property (nonatomic, strong) NSDate *selectedTime;
- (NSInteger)setNewSelectedTime:(NSDate *)date;

/**
 * Minimum time for new order
 */
@property (nonatomic, strong) NSDate *minimumTime;

@end

