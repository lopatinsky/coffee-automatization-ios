//
//  CheckOrder.m
//  DoubleB
//
//  Created by Balaban Alexander on 12/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "CheckOrder.h"

#import "OrderCoordinator.h"

@implementation CheckOrder

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    return self;
}

- (void)main {
    if (self.cancelled) return;
    
    [self setState:OperationExecuting];
    BOOL started = [[OrderCoordinator sharedInstance].promoManager checkCurrentOrder:^(BOOL success) {
        [self setState:OperationFinished];
        
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationCheckOrderSuccess object:nil userInfo:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationCheckOrderFailure object:nil userInfo:nil];
        }
    }];
    
    if (started) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationCheckOrderStarted object:nil userInfo:nil];
    } else {
        [self setState:OperationFinished];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationCheckOrderStartFailed object:nil userInfo:nil];
    }
}

@end
