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
#import "OrderCoordinator.h"
#import "ShippingManager.h"
#import "OrderItem.h"
#import "DBMenuPosition.h"

@implementation Order {
    NSArray *_items;
    NSArray *_bonusItems;
    NSArray *_giftItems;
}
@dynamic total, discount, walletDiscount, shippingTotal;
@dynamic orderId, time, timeString, dataItems, dataBonusItems, dataGiftItems, status, paymentType;
@dynamic deliveryType, venueId, venueName, shippingAddress;

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
    
    self.total = @([OrderCoordinator sharedInstance].itemsManager.totalPrice);
    self.discount = @([OrderCoordinator sharedInstance].promoManager.discount);
    if([OrderCoordinator sharedInstance].promoManager.walletActiveForOrder){
        self.walletDiscount = @([OrderCoordinator sharedInstance].promoManager.walletDiscount);
    } else {
        self.walletDiscount = @0;
    }
    self.shippingTotal = @([OrderCoordinator sharedInstance].promoManager.shippingPrice);
    
    self.dataItems = [NSKeyedArchiver archivedDataWithRootObject:[OrderCoordinator sharedInstance].itemsManager.items];
    self.dataBonusItems = [NSKeyedArchiver archivedDataWithRootObject:[OrderCoordinator sharedInstance].bonusItemsManager.items];
    self.dataGiftItems = [NSKeyedArchiver archivedDataWithRootObject:[OrderCoordinator sharedInstance].orderGiftsManager.items];
    self.paymentType = [[OrderCoordinator sharedInstance].orderManager paymentType];
    self.status = OrderStatusNew;
    
    // Delivery
    self.deliveryType = @([OrderCoordinator sharedInstance].deliverySettings.deliveryType.typeId);
    if([OrderCoordinator sharedInstance].deliverySettings.deliveryType.typeId == DeliveryTypeIdShipping){
        self.shippingAddress = [[OrderCoordinator sharedInstance].shippingManager.selectedAddress formattedAddressString:DBAddressStringModeFull];
    } else {
        self.venueId = [OrderCoordinator sharedInstance].orderManager.venue.venueId;
        self.venueName = [OrderCoordinator sharedInstance].orderManager.venue.title;
    }
    
    [self setTimeFromResponseDict:dict];
    
    [[CoreDataHelper sharedHelper] save];
    
    return self;
}

- (instancetype)initWithResponseDict:(NSDictionary *)dict{
    self = [self init:YES];
    
    self.orderId = [NSString stringWithFormat:@"%@", dict[@"order_id"]];
    
    // Assemble items
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDict in dict[@"items"]) {
        OrderItem *item = [OrderItem orderItemFromResponceDict:itemDict];
        item.position.mode = DBMenuPositionModeRegular;
        [items addObject:item];
    }
    self.dataItems = [NSKeyedArchiver archivedDataWithRootObject:items];
    
    // Assemble gift items
    NSMutableArray *giftItems = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDict in dict[@"gifts"]) {
        OrderItem *item = [OrderItem orderItemFromResponceDict:itemDict];
        item.position.mode = DBMenuPositionModeGift;
        [giftItems addObject:item];
    }
    self.dataGiftItems = [NSKeyedArchiver archivedDataWithRootObject:giftItems];
    
    self.paymentType = [dict[@"payment_type_id"] intValue] + 1;
    self.status = [dict[@"status"] intValue];
    
    [self setAddressFromResponseDict:dict];
    
    [self setTimeFromResponseDict:dict];
    
    self.total = [dict getValueForKey:@"menu_sum"] ?: @0;
    
    double actualTotal = [[dict getValueForKey:@"total"] doubleValue];
    self.discount = @(self.total.doubleValue - actualTotal);
    self.walletDiscount = [dict getValueForKey:@"wallet_payment"] ?: @0;
    self.shippingTotal = [dict getValueForKey:@"delivery_sum"] ?: @0;
    
    [[CoreDataHelper sharedHelper] save];
    
    return self;
}

- (void)synchronizeWithResponseDict:(NSDictionary *)dict{
    self.status = [dict[@"status"] intValue];
    
    [self setAddressFromResponseDict:dict];
    
    [self setTimeFromResponseDict:dict];
    
    [[CoreDataHelper sharedHelper] save];
}

- (void)setAddressFromResponseDict:(NSDictionary *)dict {
    self.deliveryType = dict[@"delivery_type"];
    if([self.deliveryType intValue] == DeliveryTypeIdShipping){
        DBShippingAddress *address = [[DBShippingAddress alloc] initWithDict:dict[@"address"]];
        self.shippingAddress = [address formattedAddressString:DBAddressStringModeFull];
    } else {
        Venue *venue = [Venue venueById:dict[@"venue_id"]];
        self.venueId = venue.venueId;
        self.venueName = venue.title;
    }
}

- (void)setTimeFromResponseDict:(NSDictionary *)dict{
    // Using this if we lose some history order information on backend
    @try {
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
    @catch (NSException *exception) {
    }
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

+ (Order *)orderById:(NSString *)orderId {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    request.predicate = [NSPredicate predicateWithFormat:@"orderId == %@", orderId];
    request.fetchLimit = 1;
    
    NSArray *venues = [[CoreDataHelper sharedHelper].context executeFetchRequest:request error:nil];
    return [venues count] > 0 ? venues[0] : nil;
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

- (double)actualTotal {
    return self.total.doubleValue + self.shippingTotal.doubleValue;
}

- (double)actualDiscount {
    return self.discount.doubleValue + self.walletDiscount.doubleValue;
}

- (NSArray *)items {
    if (!_items) {
        _items = [NSKeyedUnarchiver unarchiveObjectWithData:self.dataItems];
    }
    
    return _items;
}

- (NSArray *)bonusItems{
    if (!_bonusItems) {
        _bonusItems = [NSKeyedUnarchiver unarchiveObjectWithData:self.dataBonusItems];
    }
    
    return _bonusItems;
}

- (NSArray *)giftItems{
    if (!_giftItems) {
        _giftItems = [NSKeyedUnarchiver unarchiveObjectWithData:self.dataGiftItems];
    }
    
    return _giftItems;
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
