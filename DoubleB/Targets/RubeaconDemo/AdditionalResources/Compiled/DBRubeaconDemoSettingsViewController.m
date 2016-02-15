//
//  DBRubeaconDemoSettingsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBRubeaconDemoSettingsViewController.h"
#import "AppDelegate.h"
#import "DBCompaniesManager.h"
#import "DBCompanyInfo.h"
#import "DBDemoLoginViewController.h"
#import "DBAPIClient.h"

@interface DBRubeaconDemoSettingsViewController ()
@property (strong, nonatomic) NSMutableArray *settingsItems;
@end

@implementation DBRubeaconDemoSettingsViewController

- (NSMutableArray *)settingsSections {
    NSMutableArray *settingsSections = [super settingsSections];
    
    DBSettingsSection *section = [[DBSettingsSection alloc] init:DBSettingsSectionTypeOther];
    [section.items addObject:[DBDemoLoginViewController settingsItem]];
    
    [settingsSections insertObject:section atIndex:0];
    
    return settingsSections;
}

@end
