//
//  FetchUnifiedPositions.m
//  DoubleB
//
//  Created by Balaban Alexander on 10/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "FetchUnifiedPositions.h"
#import "DBUnifiedAppManager.h"

@interface FetchUnifiedPositions()

@property (nonatomic, strong) NSDictionary *userInfo;

@end

@implementation FetchUnifiedPositions

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    self.userInfo = userInfo;
    return self;
}

- (void)main {
    if (self.cancelled) return;
    [self setState:OperationExecuting];
    
    [[DBUnifiedAppManager sharedInstance] fetchPositionsWithId:self.userInfo[@"product_id"] withCallback:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationUnifiedPositionsLoadSuccess object:nil userInfo:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationUnifiedPositionsLoadFailure object:nil userInfo:nil];
        }
        [self setState:OperationFinished];
    }];
}

@end
