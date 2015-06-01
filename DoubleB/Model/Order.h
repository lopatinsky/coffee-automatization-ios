//
//  Order.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef NS_ENUM(int16_t, OrderStatus) {
    OrderStatusNew,
    OrderStatusDone,
    OrderStatusCanceled,
    OrderStatusCanceledServer
};

typedef NS_ENUM(int16_t, PaymentType) {
    PaymentTypeNotSet = 0,
    PaymentTypeCash,
    PaymentTypeCard,
    PaymentTypeExtraType
};

@class Venue;

@interface Order : NSManagedObject

//stored
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *timeString;
@property (nonatomic, strong) NSData *dataItems; //array of JSON-encoded positions
@property (nonatomic) OrderStatus status;
@property (nonatomic, strong) Venue *venue;
@property (nonatomic) PaymentType paymentType;

//not stored
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSString *formattedTimeString;

- (instancetype)init:(BOOL)stored;

+ (NSArray *)allOrders;
+ (void)dropOrdersHistoryIfItIsFirstLaunchOfSomeVersions;

/**
* Fetch statuses for given Order objects
*/
+ (void)synchronizeStatusesForOrders:(NSArray *)orders withCompletionHandler:(void(^)(BOOL success, NSArray *orders))completionHandler;

@end
