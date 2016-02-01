//
//  DBWatchInteractionManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 22/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "WatchInteractionManager.h"
#import "Order.h"
#import "OrderItem.h"
#import "OrderWatch.h"
#import "OrderCoordinator.h"
#import "DeliverySettings.h"
#import "NSDictionary+NSNullRepresentation.h"

#import "DBServerAPI.h"

@import WatchConnectivity;

@interface WatchInteractionManager () <WCSessionDelegate>

@property (nonatomic, strong) WCSession *session;

@end

@implementation WatchInteractionManager

- (instancetype)init {
    self = [super init];
    
    if ([WCSession isSupported]) {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
    }
    
    return self;
}

- (void)updateLastOrActiveOrder {
    if (![WCSession isSupported]) { return; }
    
    [self sendData:[self completeOrderDictionary]];
}

- (NSDictionary *)completeOrderDictionary {
    Order *lastActiveOrder = [Order lastOrderForWatch:YES];
    if (lastActiveOrder) {
        return [self orderDictionary:lastActiveOrder];
    } else {
        Order *lastOrder = [Order lastOrderForWatch:NO];
        return [self orderDictionary:lastOrder];
    }
}

- (NSDictionary *)orderDictionary:(Order *)order {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[[order watchInstance] plistRepresentation]];
    
    if (![dictionary getValueForKey:@"requestObject"] || ![[dictionary getValueForKey:@"requestObject"] count]) {
        [dictionary setObject:[self assembleOrderInfo:order] forKey:@"requestObject"];
    }
    NSArray *timeSlots = [[[[OrderCoordinator sharedInstance] deliverySettings] deliveryType] timeSlots];
    NSMutableArray *temp = [NSMutableArray new];
    for (DBTimeSlot *slot in timeSlots) {
        [temp addObject:@{@"id": slot.slotId, @"title": slot.slotTitle, @"dict": slot.slotDict}];
    }
    dictionary[@"delivery_slots"] = temp;
    
    return dictionary;
}

- (NSDictionary *)assembleOrderInfo:(Order *)order {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    params[@"client"] = [DBServerAPI assembleClientInfo];
    params[@"items"] = [self assembleOrderItems:order];
    params[@"total_sum"] = [order total];
    params[@"delivery_sum"] = [order shippingTotal];
    params[@"payment"] = [DBServerAPI assemblyPaymentInfo];
    params[@"comment"] = @"Reorder from apple watch";
    params[@"device_type"] = @(0);
    [DBServerAPI assembleTimeIntoParams:params];
    [DBServerAPI assembleDeliveryInfoIntoParams:params encode:NO];
    
    return  params;
}

- (NSArray *)assembleOrderItems:(Order *)order {
    NSMutableArray *items = [NSMutableArray new];
    for (OrderItem *item in [order items]) {
        [items addObject:[item requestJson]];
    }
    
    return items;
}

- (void)continueUserActivity:(NSUserActivity *)activity {
    if ([activity.activityType isEqualToString:@"com.empatika.openorder"]) {
        NSString *orderId = [activity.userInfo objectForKey:@"order_id"];
        [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenHistoryOrder object:orderId animated:YES];
    } else if ([activity.activityType isEqualToString:@"com.empatika.neworder"]) {
        [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenOrder object:nil animated:YES];
    }
}

- (void)sendData:(NSDictionary *)info {
    if (self.session.reachable) {
        [self.session sendMessage:info replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            NSLog(@"%@", replyMessage);
        } errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
    } else {
        NSError *error;
        [self.session updateApplicationContext:info error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

#pragma mark - WCSessionDelegate
- (void)sessionReachabilityDidChange:(WCSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (session.reachable) {
        [self updateLastOrActiveOrder];
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message
                                          replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    if ([message objectForKey:@"request"]) {
        replyHandler(@{@"order": [self completeOrderDictionary] ?: @""});
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    if ([applicationContext objectForKey:@"request"]) {
        [self sendData:@{@"order": [self completeOrderDictionary] ?: @""}];
    }
}

- (void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([userInfo objectForKey:@"operation"]) {
        NSString *op = [userInfo objectForKey:@"operation"];
        if ([op isEqualToString:@"update_venue"]) {
            [[WatchInteractionManager sharedInstance] updateLastOrActiveOrder];
        }
    }
}

@end
