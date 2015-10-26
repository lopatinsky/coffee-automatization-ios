//
//  FetchSubscriptionData.m
//  DoubleB
//
//  Created by Balaban Alexander on 26/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "FetchSubscriptionData.h"
#import "DBSubscriptionManager.h"

@implementation FetchSubscriptionData

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    return self;
}

- (void)main {
    if (self.cancelled) return;
    
    [[DBSubscriptionManager sharedInstance] checkSubscriptionVariants:^(NSArray *variants) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationFetchSubscriptionInfoSuccess object:nil];
        [self setState:OperationFinished];
    } failure:^(NSString *errorMessage) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationFetchSubscriptionInfoFailure object:nil];
        [self setState:OperationFinished];
    }];
}

@end
