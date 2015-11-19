//
//  FetchVenues.m
//  DoubleB
//
//  Created by Balaban Alexander on 12/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "FetchVenues.h"

#import "Venue.h"

@interface FetchVenues()

@property (nonatomic, strong) CLLocation *location;

@end

@implementation FetchVenues

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
    [Venue fetchVenuesForLocation:self.location withCompletionHandler:^(NSArray *venues) {
        if (self.notifyOnCompletion) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationFetchVenuesFinished object:nil];
        }
        [self setState:OperationFinished];
    }];
}

@end
