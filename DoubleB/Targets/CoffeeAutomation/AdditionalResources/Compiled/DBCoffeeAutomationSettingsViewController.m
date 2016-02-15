//
//  DBCoffeeAutomationSettingsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCoffeeAutomationSettingsViewController.h"
#import "DBApplicationSettingsViewController.h"

@interface DBCoffeeAutomationSettingsViewController ()
@end

@implementation DBCoffeeAutomationSettingsViewController

- (NSMutableArray *)settingsSections {
    NSMutableArray *settingsSections = [super settingsSections];
    
    DBSettingsSection *section = [[DBSettingsSection alloc] init:DBSettingsSectionTypeOther];
    [section.items addObject:[DBApplicationSettingsViewController settingsItem]];
    
    [settingsSections insertObject:section atIndex:0];
    
    return settingsSections;
}

@end
