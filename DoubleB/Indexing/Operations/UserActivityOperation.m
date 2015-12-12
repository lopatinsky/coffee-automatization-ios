//
//  UserActivityOperation.m
//  DoubleB
//
//  Created by Balaban Alexander on 06/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "UserActivityOperation.h"
#import "AppIndexingManager.h"

@interface UserActivityOperation()

@property (nonatomic, strong) NSUserActivity *userActivity;
@property (nonatomic, weak) id<UserActivityIndexing> obj;

@end

@implementation UserActivityOperation

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    _userActivity = [userInfo objectForKey:@"activity"];
    _obj = [userInfo objectForKey:@"obj"];
    return self;
    
}

- (void)main {
    if (self.cancelled) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.userActivity becomeCurrent];
        [self.obj activityDidAppear];
        [self setState:OperationFinished];
    });
}

@end
