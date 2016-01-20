//
//  DBClassLoader.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBClassLoader.h"

@implementation DBClassLoader

+ (UIViewController *)loadSettingsViewController{
    Class settingsVCClass = NSClassFromString(@"DBCoffeeAutomationSettingsViewController");
    
    if (!settingsVCClass) {
        settingsVCClass = NSClassFromString(@"DBCompanySettingsTableViewController");
    }
    
    
    return [[settingsVCClass alloc] init];
}

+ (UIViewController *)loadNewOrderViewController{
//    Class newOrderVCClass = NSClassFromString(@"DBCatNewOrderViewController");
//    
//    if(!newOrderVCClass){
//        newOrderVCClass = NSClassFromString(@"DBNewOrderViewController");
//    }
//    
//    return [[newOrderVCClass alloc] initWithNibName:@"DBNewOrderViewController" bundle:[NSBundle mainBundle]];
    Class newOrderVCClass = NSClassFromString(@"DBNewOrderVC");
    return [[newOrderVCClass alloc] init];
}

+ (UIViewController *)loadDemoLoginViewController{
    Class loginVCClass = NSClassFromString(@"DBDemoLoginViewController");
    
    if(loginVCClass){
        return [[loginVCClass alloc] init];
    } else {
        return nil;
    }
}

#pragma mark - Views
+ (Class)menuCategoryCell {
    Class categoryCellClass = NSClassFromString(@"DBCategoryCellCoffeeAcademy");
    
    if(!categoryCellClass){
        categoryCellClass = NSClassFromString(@"DBCategoryCell");
    }
    
    return categoryCellClass;
}

@end