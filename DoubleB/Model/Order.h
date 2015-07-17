//
//  Order.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef NS_ENUM(int16_t, OrderStatus) {
    OrderStatusNew = 0,
    OrderStatusConfirmed = 5,
    OrderStatusOnWay = 6,
    OrderStatusDone = 1,
    OrderStatusCanceled = 2,
    OrderStatusCanceledBarista = 3
};

typedef NS_ENUM(int16_t, PaymentType) {
    PaymentTypeNotSet = -1,
    PaymentTypeCash = 0,
    PaymentTypeCard = 1,
    PaymentTypePayPal = 4,
    PaymentTypeExtraType = 2
};

@class Venue;

@interface Order : NSManagedObject

//stored
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *timeString;
@property (nonatomic, strong) NSData *dataItems; //array of JSON-encoded positions
@property (nonatomic, strong) NSData *dataGifts; //array of JSON-encoded gift positions

@property (nonatomic) OrderStatus status;

@property (nonatomic, strong) NSNumber *deliveryType;
@property (nonatomic, strong) Venue *venue;
@property (nonatomic, strong) NSString *shippingAddress;

@property (nonatomic) PaymentType paymentType;

//not stored
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSArray *bonusItems;
@property (nonatomic, readonly) NSString *formattedTimeString;
@property (nonatomic, strong) NSNumber *realTotal;

- (instancetype)init:(BOOL)stored;
- (instancetype)initNewOrderWithDict:(NSDictionary *)dict;
- (instancetype)initWithResponseDict:(NSDictionary *)dict;
- (void)synchronizeWithResponseDict:(NSDictionary *)dict;

+ (NSArray *)allOrders;
+ (void)dropOrdersHistoryIfItIsFirstLaunchOfSomeVersions;
+ (void)dropAllOrders;

/**
* Fetch statuses for given Order objects
*/
+ (void)synchronizeStatusesForOrders:(NSArray *)orders withCompletionHandler:(void(^)(BOOL success, NSArray *orders))completionHandler;

@end
