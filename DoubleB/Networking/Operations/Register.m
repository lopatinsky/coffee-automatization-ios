//
//  Register.m
//  DoubleB
//
//  Created by Balaban Alexander on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "Register.h"

#import "DBServerAPI.h"
#import <Branch/Branch.h>

@interface Register()

@property (nonatomic, strong) NSDictionary *launchOptions;

@end

@implementation Register

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    if (userInfo) {
        _launchOptions = [userInfo getValueForKey:@"launchOptions"] ?: @{};
    }
    return self;
}

- (void)main {
    if (self.cancelled) return;
    
    [self setState:OperationExecuting];
    
    Branch *branchInstance = [Branch getInstance];
    if ([ApplicationConfig sharedInstance].branchKey) {
        branchInstance = [Branch getInstance:[ApplicationConfig sharedInstance].branchKey];
    }
    
    [[Branch getInstance] initSessionWithLaunchOptions:self.launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (error) {
            [DBServerAPI registerUser:^(BOOL success) {
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationRegisterSuccess object:nil];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationRegisterFailure object:nil];
                }
                [self setState:OperationFinished];
            }];
        } else {
            [DBServerAPI registerUserWithBranchParams:params callback:^(BOOL success) {
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationRegisterSuccess object:nil];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationRegisterFailure object:nil];
                }
                [self setState:OperationFinished];
            }];
        }
    }];
}

@end
