//
//  FetchUnifiedVenues.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "FetchUnifiedVenues.h"
#import "Venue.h"

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
    
    [Venue fetchUnifiedVenuesForLocation:self.location withCompletionHandler:^(NSArray *venues) {
        if (venues) {
            
        }
    }];
}

@end
