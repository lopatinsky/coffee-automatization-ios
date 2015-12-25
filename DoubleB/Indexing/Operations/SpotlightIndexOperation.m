//
//  SpotlightIndexOperation.m
//  DoubleB
//
//  Created by Balaban Alexander on 06/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <CoreSpotlight/CoreSpotlight.h>

#import "SpotlightIndexOperation.h"

@interface SpotlightIndexOperation()

@property (nonatomic, strong) CSSearchableItem *item;

@end

@implementation SpotlightIndexOperation

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    _item = [userInfo objectForKey:@"spotlight"];
    return self;
}

- (void)main {
    if (self.cancelled) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[self.item] completionHandler:^(NSError * _Nullable error) {
            [self setState:OperationFinished];
        }];
    });
}

@end
