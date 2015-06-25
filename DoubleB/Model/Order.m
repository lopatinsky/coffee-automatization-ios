//
//  Order.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "Order.h"
#import "Venue.h"
#import "CoreDataHelper.h"
#import "DBAPIClient.h"
#import "OrderManager.h"
#import "DBShippingManager.h"
#import "OrderItem.h"

@implementation Order {
    NSArray *_items;
    NSArray *_bonusItems;
}
@dynamic orderId, total, time, timeString, dataItems, dataGifts, status, deliveryType, venue, shippingAddress, paymentType;

- (instancetype)init:(BOOL)stored {
    if (stored) {
        return [self initWithEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext:[CoreDataHelper sharedHelper].context] insertIntoManagedObjectContext:[CoreDataHelper sharedHelper].context];
    } else {
        return [self initWithEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext:nil] insertIntoManagedObjectContext:nil];
    }
}

- (instancetype)initNewOrderWithDict:(NSDictionary *)dict{
    self = [self init:YES];
    
    self.orderId = [NSString stringWithFormat:@"%@", dict[@"order_id"]];
    self.total = @([[OrderManager sharedManager] totalPrice]);
    self.dataItems = [NSKeyedArchiver archivedDataWithRootObject:[OrderManager sharedManager].items];
    self.dataGifts = [NSKeyedArchiver archivedDataWithRootObject:[OrderManager sharedManager].bonusPositions];
    self.paymentType = [[OrderManager sharedManager] paymentType];
    self.status = OrderStatusNew;
    
    // Delivery
    self.deliveryType = @([DBDeliverySettings sharedInstance].deliveryType.typeId);
    if([DBDeliverySettings sharedInstance].deliveryType.typeId == DeliveryTypeIdShipping){
        self.shippingAddress = [[DBShippingManager sharedManager].selectedAddress formattedAddressString:DBAddressStringModeFull];
    } else {
        self.venue = [OrderManager sharedManager].venue;
    }
    
    [self setTimeFromResponseDict:dict];
    
    [[CoreDataHelper sharedHelper] save];
    
    return self;
}

- (instancetype)initWithResponseDict:(NSDictionary *)dict{
    self = [self init:YES];
    
    self.orderId = [NSString stringWithFormat:@"%@", dict[@"order_id"]];
    self.total = dict[@"total"];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDict in dict[@"items"]) {
        [items addObject:[OrderItem orderItemFromHistoryDictionary:itemDict bonus:NO]];
    }
    self.dataItems = [NSKeyedArchiver archivedDataWithRootObject:items];
    
    NSMutableArray *bonusItems = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDict in dict[@"gifts"]) {
        [bonusItems addObject:[OrderItem orderItemFromHistoryDictionary:itemDict bonus:YES]];
    }
    self.dataGifts = [NSKeyedArchiver archivedDataWithRootObject:bonusItems];
    
    self.paymentType = [dict[@"payment_type_id"] intValue] + 1;
    self.status = [dict[@"status"] intValue];
    
    // Delivery
    self.deliveryType = dict[@"delivery_type"];
    if([self.deliveryType intValue] == DeliveryTypeIdShipping){
        DBShippingAddress *address = [[DBShippingAddress alloc] initWithDict:dict[@"address"]];
        self.shippingAddress = [address formattedAddressString:DBAddressStringModeFull];
    } else {
        self.venue = [Venue venueById:dict[@"venue_id"]];
    }
    
    [self setTimeFromResponseDict:dict];
    
    [[CoreDataHelper sharedHelper] save];
    
    return self;
}

- (void)synchronizeWithResponseDict:(NSDictionary *)dict{
    self.status = [dict[@"status"] intValue];
    [self setTimeFromResponseDict:dict];
    
    [[CoreDataHelper sharedHelper] save];
}

- (void)setTimeFromResponseDict:(NSDictionary *)dict{
    NSString *dateString = [dict getValueForKey:@"delivery_time_str"];
    if(!dateString){
        dateString = [dict getValueForKey:@"delivery_time"];
    }
    
    NSString *timeSlot = [dict getValueForKey:@"delivery_slot_name"];
    if(!timeSlot){
        timeSlot = [dict getValueForKey:@"delivery_slot_str"];
    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [formatter dateFromString:dateString];
    
    self.time = date;
    if(timeSlot)
        self.timeString = timeSlot;
}

+ (void)dropOrdersHistoryIfItIsFirstLaunchOfSomeVersions{
    NSString *lastMajorUpdateVersion = @"1.2";
    
    NSString *fieldName = [NSString stringWithFormat:@"launchedBeforeVersion_%@", lastMajorUpdateVersion];
    BOOL isLaunchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:fieldName];
    
    if(!isLaunchedBefore){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fieldName];
        [Order dropAllOrders];
    }
}

+ (void)dropAllOrders{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    
    NSArray *orders = [[CoreDataHelper sharedHelper].context executeFetchRequest:request error:nil];
    
    for(Order *order in orders){
        [[CoreDataHelper sharedHelper].context deleteObject:order];
    }
}

+ (NSArray *)allOrders {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
    
    NSArray *orders = [[CoreDataHelper sharedHelper].context executeFetchRequest:request error:nil];
    
    return orders;
}

+ (void)synchronizeStatusesForOrders:(NSArray *)orders withCompletionHandler:(void(^)(BOOL success, NSArray *orders))completionHandler {
    NSMutableArray *orderIds = [NSMutableArray array];
    for (Order *order in orders) {
        [orderIds addObject:order.orderId];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"orders": orderIds}
                                                       options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[DBAPIClient sharedClient] POST:@"status"
                          parameters:@{
                                       @"orders": jsonString
                             }
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%s %@", __PRETTY_FUNCTION__, responseObject);
                                 for (NSDictionary *status in responseObject[@"status"]) {
                                     for (Order *order in orders) {
                                         if ([status[@"order_id"] isEqualToString:order.orderId]) {
                                             order.status = ([status[@"status"] intValue]);
                                         }
                                     }
                                 }
                                 [[CoreDataHelper sharedHelper] save];
                                 if (completionHandler) {
                                     completionHandler(YES, orders);
                                 }
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
                                 if (completionHandler) {
                                     completionHandler(NO, nil);
                                 }
                             }];
}

- (NSArray *)items {
    if (!_items) {
        _items = [NSKeyedUnarchiver unarchiveObjectWithData:self.dataItems];
    }
    
    return _items;
}

- (NSArray *)bonusItems{
    if (!_bonusItems) {
        _bonusItems = [NSKeyedUnarchiver unarchiveObjectWithData:self.dataGifts];
    }
    
    return _bonusItems;
}

- (NSString *)formattedTimeString{
    if(self.timeString){
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"dd.MM.yy";
        
        return [NSString stringWithFormat:@"%@, %@", [formatter stringFromDate:self.time], self.timeString];
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"dd.MM.yy, HH:mm";
        
        return [formatter stringFromDate: self.time];
    }
}


@end
