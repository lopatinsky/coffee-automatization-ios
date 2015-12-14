//
//  ExtensionDelegate.m
//  Camera Obscura Extension
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "ApplicationInteractionManager.h"

#import "OrderWatch.h"

NSString * __nonnull const kWatchNetworkManagerOrderUpdated = @"kWatchNetworkManagerOrderUpdated";

@interface ExtensionDelegate()

@property (nonatomic, strong) ApplicationInteractionManager *interactionManager;

@end

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    self.interactionManager = [ApplicationInteractionManager sharedManager];
    self.interactionManager.delegate = self;
    
    [self.interactionManager openSession];
    [self updateRoot];
}

- (void)updateRoot {
    OrderWatch *currentOrder = [self.interactionManager currentOrder];
    
    if (currentOrder) {
        if ([currentOrder active]) {
            [WKInterfaceController reloadRootControllersWithNames:@[@"CurrentOrder"] contexts:nil];
        } else {
            [WKInterfaceController reloadRootControllersWithNames:@[@"LastOrder"] contexts:nil];
        }
    } else {
        [WKInterfaceController reloadRootControllersWithNames:@[@"AddOrder"] contexts:nil];
    }
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

@end
