//
//  DBClassLoader.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBClassLoader.h"

@implementation DBClassLoader

+ (DBCompaniesViewController *)loadStartNavigationController{
    Class navVCClass = NSClassFromString(@"DBDemoStartNavController");
    
    if (!navVCClass) {
        navVCClass = NSClassFromString(@"DBCommonStartNavController");
    }
    
    return [[navVCClass alloc] init];
}

+ (DBBaseSettingsTableViewController *)loadSettingsViewController {
    Class settingsVCClass = NSClassFromString(@"DBCoffeeAutomationSettingsViewController");
    
    if (!settingsVCClass) {
        settingsVCClass = NSClassFromString(@"DBRubeaconDemoSettingsViewController");
    }
    
    if (!settingsVCClass) {
        settingsVCClass = NSClassFromString(@"DBCompanySettingsTableViewController");
    }
    
    return [[settingsVCClass alloc] init];
}
+ (DBNewOrderVC *)loadNewOrderVC {
    Class newOrderVCClass = NSClassFromString(@"DBCosmothecaNewOrderVC");
    
    if (!newOrderVCClass) {
        newOrderVCClass = NSClassFromString(@"DBNewOrderVC");
    }
    return [[newOrderVCClass alloc] init];
}

#pragma mark - Views

+ (Class<DBCategoryCellProtocol>)loadCategoryCell {
    Class categoryCellClass = NSClassFromString(@"DBCategoryCellCoffeeAcademy");
    
    if (!categoryCellClass) {
        categoryCellClass = NSClassFromString(@"DBSushilarCategoryCell");
    }
    
    if (!categoryCellClass) {
        categoryCellClass = NSClassFromString(@"DBCategoryCell");
    }
    
    return categoryCellClass;
}

@end