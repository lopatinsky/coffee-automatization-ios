//
//  DBClassLoader.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBClassLoader.h"
#import "DBTabBarController.h"

@implementation DBClassLoader

+ (UIViewController *)loadFirstViewController{
    Class firstVCClass = NSClassFromString(@"DBDemoLoginViewController");
    
    if(!firstVCClass){
        firstVCClass = NSClassFromString(@"DBTabBarController");
    }
    
    UIViewController *firstVC;
    if([NSStringFromClass(firstVCClass) isEqualToString:@"DBTabBarController"]){
        firstVC = [DBTabBarController sharedInstance];
    } else {
        firstVC = [firstVCClass new];
    }
    return firstVC;
}

+ (DBSettingsTableViewController *)loadSettingsViewController{
    Class settingsVCClass = NSClassFromString(@"DBCoffeeAutomationSettingsViewController");
    
    if(!settingsVCClass){
        settingsVCClass = NSClassFromString(@"DBSettingsTableViewController");
    }
    
    return [[settingsVCClass alloc] init];
}

+ (DBNewOrderViewController *)loadNewOrderViewController{
    Class newOrderVCClass = NSClassFromString(@"DBCatNewOrderViewController");
    
    if(!newOrderVCClass){
        newOrderVCClass = NSClassFromString(@"DBNewOrderViewController");
    }
    
    return [[newOrderVCClass alloc] initWithNibName:@"DBNewOrderViewController" bundle:[NSBundle mainBundle]];
}

@end
