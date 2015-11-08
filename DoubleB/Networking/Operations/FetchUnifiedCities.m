//
//  FetchUnifiedCities.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "FetchUnifiedCities.h"
#import "DBAPIClient.h"

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
    
    [[DBAPIClient sharedClient] GET:@"unified/cities"
                         parameters:@[]
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                
                            }
                            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                            }];
}

@end
