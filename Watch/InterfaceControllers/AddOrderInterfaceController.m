//
//  AddOrderInterfaceController.m
//  DoubleB
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ApplicationInteractionManager.h"

#import "AddOrderInterfaceController.h"
#import "LastOrderInterfaceController.h"
#import "CurrentOrderInterfaceController.h"

@interface AddOrderInterfaceController ()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *informationLabel;

@end

@implementation AddOrderInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self updateInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:kWatchNetworkManagerOrderUpdated object:nil];
}

- (void)updateInfo {
    OrderWatch *order = [[ApplicationInteractionManager sharedManager] currentOrder];
    if (order) {
        if (order.status == 0 || order.status == 5 || order.status == 6) {
            [WKInterfaceController reloadRootControllersWithNames:@[@"CurrentOrder"] contexts:nil];
        } else {
            [WKInterfaceController reloadRootControllersWithNames:@[@"LastOrder"] contexts:nil];
        }
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [self updateUserActivity:@"com.empatika.neworder" userInfo:@{} webpageURL:nil];
    [[ApplicationInteractionManager sharedManager] postMessageToApplication:@{@"request": @"last_order"}];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [self invalidateUserActivity];
    [super didDeactivate];
}

@end



