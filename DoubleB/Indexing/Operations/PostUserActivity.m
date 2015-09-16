//
//  PosUserActivity.m
//  DoubleB
//
//  Created by Balaban Alexander on 16/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "PostUserActivity.h"

@interface PostUserActivity()

@property (nonatomic, strong) id<UserActivityIndexing> obj;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSUserActivity *activity;

@end

@implementation PostUserActivity

- (instancetype)initWithObject:(id<UserActivityIndexing>)obj andParams:(NSDictionary *)params {
    self = [super init];
    _obj = obj;
    _params = params;
    return self;
}

- (void)main {
    if (self.cancelled) return;
    
    self.activity = [[NSUserActivity alloc] initWithActivityType:[self.params objectForKey:@"type"] ?: @"default"];
    
    self.activity.title = [self.obj activityTitle];
    self.activity.userInfo = [self.obj activityUserInfo];
    self.activity.contentAttributeSet = [self.obj activityAttributes];
    self.activity.expirationDate = [self.params objectForKey:@"expirationDate"] ?: [NSDate distantFuture];
    
    self.activity.eligibleForSearch = [self.params objectForKey:@"eligibleForSearch"] ?: @(YES);
    self.activity.eligibleForHandoff = [self.params objectForKey:@"eligibleForHandoff"] ?: @(NO);
    self.activity.eligibleForPublicIndexing = [self.params objectForKey:@"eligibleForPublicIndexing"] ?: @(NO);
    
    [self.activity becomeCurrent];
    [self.obj activityDidAppear];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setState:OperationFinished];
    });
}

@end
