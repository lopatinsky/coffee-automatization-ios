//
//  ApplicationInteractionManager.m
//  DoubleB
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

@import WatchConnectivity;

#import <ClockKit/ClockKit.h>

#import "ApplicationInteractionManager.h"

@interface ApplicationInteractionManager() <WCSessionDelegate>

@property (nonatomic, strong) WCSession *session;
@property (nonatomic, strong) OrderWatch *currentOrder;

@end

@implementation ApplicationInteractionManager

+ (instancetype)sharedManager {
    static ApplicationInteractionManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ApplicationInteractionManager new];
    });
    return instance;
}

- (void)openSession {
    if ([WCSession isSupported]) {
        self.session = [WCSession defaultSession];
        self.session.delegate = self;
        [self.session activateSession];
        NSDictionary *lastMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_order"];
        if (lastMessage) {
            self.currentOrder = [OrderWatch createWithPlistRepresentation:lastMessage];
        }
    }
}

- (OrderWatch *)currentOrder {
    return _currentOrder;
}

#pragma mark - User-defined protocol
- (void)postMessageToApplication:(nonnull NSDictionary<NSString *,id> *)msg {
    if (self.session.reachable) {
        [self.session sendMessage:msg replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            if ([replyMessage objectForKey:@"order"] && [[replyMessage objectForKey:@"order"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *orderDictionary = replyMessage[@"order"];
                self.currentOrder = [OrderWatch createWithPlistRepresentation:orderDictionary];
                [[NSNotificationCenter defaultCenter] postNotificationName:kWatchNetworkManagerOrderUpdated object:nil];
            }
        } errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
    } else {
        NSError *error;
        [self.session updateApplicationContext:msg error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

- (void)saveOrder:(OrderWatch *)owatch {
    [[NSUserDefaults standardUserDefaults] setObject:[owatch plistRepresentation] forKey:@"current_order"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateComplications];
}

- (void)cancelOrder {
    self.currentOrder = [[ApplicationInteractionManager sharedManager] currentOrder];
    self.currentOrder.active = NO;
    [self saveOrder:self.currentOrder];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWatchNetworkManagerOrderUpdated object:nil];
    [self updateComplications];
}

- (void)makeReorder:(NSString *)newOrderId {
    self.currentOrder = [[ApplicationInteractionManager sharedManager] currentOrder];
    self.currentOrder.orderId = newOrderId;
    self.currentOrder.active = YES;
    [self saveOrder:self.currentOrder];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWatchNetworkManagerOrderUpdated object:nil];
    [self updateComplications];
}

- (void)updateComplications {
    CLKComplicationServer *server = [CLKComplicationServer sharedInstance];
    for (CLKComplication *complication in server.activeComplications) {
        [server reloadTimelineForComplication:complication];
    }
}

#pragma mark - WCSessionDelegate protocol

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    [[NSUserDefaults standardUserDefaults] setObject:message forKey:@"current_order"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.currentOrder = [OrderWatch createWithPlistRepresentation:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWatchNetworkManagerOrderUpdated object:nil];
    [self updateComplications];
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    if ([applicationContext objectForKey:@"order"] && [[applicationContext objectForKey:@"order"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *orderDictionary = applicationContext[@"order"];
        self.currentOrder = [OrderWatch createWithPlistRepresentation:orderDictionary];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:applicationContext forKey:@"current_order"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.currentOrder = [OrderWatch createWithPlistRepresentation:applicationContext];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kWatchNetworkManagerOrderUpdated object:nil];
    [self updateComplications];
}

@end
