//
//  DBSnapshotSDKHelper.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 01/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBSnapshotSDKHelper.h"

#import <HSTestingBackchannel/HSTestingBackchannel.h>

#import "DBTabBarController.h"

@implementation DBSnapshotSDKHelper

+ (instancetype)sharedInstance {
    static DBSnapshotSDKHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DBSnapshotSDKHelper new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    [HSTestingBackchannel installReceiver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveToOrder)
                                                 name:@"SnapshotTest"
                                               object:nil];
    
    return self;
}

- (void)moveToOrder {
    UINavigationController *navVC = [DBTabBarController sharedInstance].viewControllers.firstObject;
    [navVC popToRootViewControllerAnimated:NO];
}

@end
