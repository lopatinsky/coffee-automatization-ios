//
//  DBWatchInteractionManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 22/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "WatchInteractionManager.h"
#import "Order.h"
#import "OrderWatch.h"
#import "OrderCoordinator.h"
#import "DeliverySettings.h"

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
    
    Order *lastOrder = [Order lastOrderForWatch:NO];
    if (lastOrder) {
        [self sendData:[self orderDictionary]];
    }
}

- (NSDictionary *)orderDictionary {
    Order *lastOrder = [Order lastOrderForWatch:NO];
    if ([lastOrder isActive]) {
        return [self lastActiveOrderInfo];
    } else {
        return [self lastOrderInfo];
    }
}

- (NSDictionary *)lastActiveOrderInfo {
    NSMutableDictionary *activeOrder = [NSMutableDictionary dictionaryWithDictionary:[[[Order lastOrderForWatch:YES] watchInstance] plistRepresentation]];
    NSArray *timeSlots = [[[[OrderCoordinator sharedInstance] deliverySettings] deliveryType] timeSlots];
    NSMutableArray *temp = [NSMutableArray new];
    for (DBTimeSlot *slot in timeSlots) {
        [temp addObject:@{@"id": slot.slotId, @"title": slot.slotTitle, @"dict": slot.slotDict}];
    }
    activeOrder[@"delivery_slots"] = temp;
    return activeOrder;
}

- (NSDictionary *)lastOrderInfo {
    Order *lastOrder = [Order lastOrderForWatch:NO];
    NSMutableDictionary *lastOrderDictionary = [NSMutableDictionary dictionaryWithDictionary:[lastOrder plistRepresentation]];
    NSArray *timeSlots = [[[[OrderCoordinator sharedInstance] deliverySettings] deliveryType] timeSlots];
    NSMutableArray *temp = [NSMutableArray new];
    for (DBTimeSlot *slot in timeSlots) {
        [temp addObject:@{@"id": slot.slotId, @"title": slot.slotTitle, @"dict": slot.slotDict}];
    }
    lastOrderDictionary[@"delivery_slots"] = temp;
    return lastOrderDictionary;
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
        replyHandler(@{@"order": [self orderDictionary] ?: @""});
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
        [self sendData:@{@"order": [self orderDictionary] ?: @""}];
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
