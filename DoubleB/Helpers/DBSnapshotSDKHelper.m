//
//  DBSnapshotSDKHelper.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 01/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBSnapshotSDKHelper.h"

#import <HSTestingBackchannel/HSTestingBackchannel.h>

#import "DBNewOrderVC.h"

#import "DBClientInfo.h"
#import "OrderCoordinator.h"
#import "DBCompanyInfo.h"

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
                                             selector:@selector(toCategoriesScreen)
                                                 name:@"UITestNotificationCategoriesScreen"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toPositionsScreen)
                                                 name:@"UITestNotificationPositionsScreen"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toPositionScreen)
                                                 name:@"UITestNotificationPositionScreen"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toOrderScreen)
                                                 name:@"UITestNotificationOrderScreen"
                                               object:nil];
    
    return self;
}

- (UINavigationController *)navController {
    UIViewController *currentVC = [UIViewController currentViewController];
    
    return currentVC.navigationController;
}

- (void)toCategoriesScreen {
    [[self navController] setViewControllers:@[[ViewControllerManager rootMenuViewController]] animated:NO];
}

- (void)toPositionsScreen {
    
}

- (void)toPositionScreen {
    
}

- (void)toOrderScreen {
    [[DBClientInfo sharedInstance] setName:@"Иван"];
    [[DBClientInfo sharedInstance] setPhone:@"79152975079"];
    
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdShipping]) {
        [[OrderCoordinator sharedInstance].shippingManager setStreet:@"Ленина"];
        [[OrderCoordinator sharedInstance].shippingManager setHome:@"15"];
        [[OrderCoordinator sharedInstance].shippingManager setApartment:@"3"];
    }
    
    [OrderCoordinator sharedInstance].orderManager.ndaAccepted = YES;
    
    
    
    DBNewOrderVC *newOrderVC = [DBNewOrderVC new];
    [[self navController] setViewControllers:@[newOrderVC] animated:NO];
}

@end
