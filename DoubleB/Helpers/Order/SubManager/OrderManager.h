//
//  OrderManager.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ManagerProtocol.h"
#import "OrderPartManagerProtocol.h"
#import "Order.h"

extern NSString* const kDBDefaultsPaymentType;

@class Venue;
@class OrderItem;
@class DBMenuBonusPosition;
@class DBDeliverySettings;

typedef NS_ENUM(NSInteger, OrderManagerChange) {
    OrderManagerChangePaymentType = 0,
    OrderManagerChangeVenue,
    OrderManagerChangeComment,
    OrderManagerChangeNDAAccept
};

/**
* Manages order
* Only one order can be managed at a time
*/
@interface OrderManager : NSObject<ManagerProtocol, OrderPartManagerProtocol>

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
 * Define if user has accepted NDA
 */
@property (nonatomic) BOOL ndaAccepted;

- (void)selectIfPossibleDefaultPaymentType;

@end

