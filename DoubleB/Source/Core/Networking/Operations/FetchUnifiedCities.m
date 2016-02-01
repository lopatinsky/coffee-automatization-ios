//
//  FetchUnifiedCities.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "FetchUnifiedCities.h"
#import "DBCitiesManager.h"

@interface FetchUnifiedCities()

@property (nonatomic, strong) NSDictionary *userInfo;

@end

@implementation FetchUnifiedCities

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    self.userInfo = userInfo;
    return self;
}

- (void)main {
    if (self.cancelled) return;
    [self setState:OperationExecuting];
    
    [[DBCitiesManager sharedInstance] fetchCities:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationUnifiedCitiesLoadSuccess object:nil userInfo:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationUnifiedCitiesLoadFailure object:nil userInfo:nil];
        }
    }];
}

@end
