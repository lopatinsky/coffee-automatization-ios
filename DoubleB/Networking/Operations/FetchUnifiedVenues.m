//
//  FetchUnifiedVenues.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "FetchUnifiedVenues.h"

#import "DBUnifiedAppManager.h"

@interface FetchUnifiedVenues()

@property (nonatomic, strong) CLLocation *location;

@end

@implementation FetchUnifiedVenues

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    if (userInfo) {
        self.location = [userInfo objectForKey:@"location"];
    }
    return self;
}

- (void)main {
    if (self.cancelled) return;
    [self setState:OperationExecuting];
    
    [[DBUnifiedAppManager sharedInstance] fetchVenues:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationUnifiedVenuesLoadSuccess object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationUnifiedVenuesLoadFailure object:nil];
        }
        [self setState:OperationFinished];
    }];
}

@end
