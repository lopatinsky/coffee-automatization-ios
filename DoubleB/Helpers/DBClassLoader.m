//
//  DBClassLoader.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBClassLoader.h"

@implementation DBClassLoader

+ (DBSettingsTableViewController *)loadSettingsViewController{
    Class settingsVCClass = NSClassFromString(@"DBCoffeeAutomationSettingsViewController");
    
    if(!settingsVCClass){
        settingsVCClass = NSClassFromString(@"DBSettingsTableViewController");
    }
    
    return [[settingsVCClass alloc] init];
}

@end