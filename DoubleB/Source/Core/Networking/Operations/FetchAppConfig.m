//
//  FetchAppConfig.m
//  DoubleB
//
//  Created by Balaban Alexander on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "FetchAppConfig.h"
#import "DBServerAPI.h"

@implementation FetchAppConfig

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    if (userInfo) {
    }
    return self;
}

- (void)main {
    if (self.cancelled) return;
    
    [self setState:OperationExecuting];
    [DBServerAPI fetchAppConfiguration:^(BOOL success, NSDictionary *response) {
        if (self.notifyOnCompletion) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationAppConfigLoadSuccess object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationAppConfigLoadFailure object:nil];
            }
        }
        [self setState:OperationFinished];
    }];
}

@end
 