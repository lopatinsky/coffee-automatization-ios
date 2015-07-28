//
//  DeliverySettings.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerProtocol.h"
#import "OrderPartManagerProtocol.h"

extern NSString *const kDBDeliverySettingsNewSelectedTimeNotification;

@interface DeliverySettings : NSObject<ManagerProtocol, OrderPartManagerProtocol>

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
