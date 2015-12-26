//
//  FetchUnifiedMenu.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "FetchUnifiedMenu.h"
#import "DBUnifiedAppManager.h"

@interface FetchUnifiedMenu()

@property (nonatomic, strong) NSDictionary *userInfo;

@end

@implementation FetchUnifiedMenu

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    self.userInfo = userInfo;
    return self;
}

- (void)main {
    if (self.cancelled) return;
    [self setState:OperationExecuting];
    
    [[DBUnifiedAppManager sharedInstance] fetchMenu:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationUnifiedMenuLoadSuccess object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationUnifiedMenuLoadFailure object:nil];
        }
        [self setState:OperationFinished];
    }];
}

@end
