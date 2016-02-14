//
//  DBGeneralSettingsTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBGeneralSettingsTableViewController.h"
#import "DBCitiesViewController.h"
#import "DBCitiesManager.h"
#import "DBUnifiedAppManager.h"

#import "DBProfileViewController.h"

@implementation DBGeneralSettingsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [self reload];
    [super viewWillAppear:animated];
}

- (NSMutableArray *)settingsSections {
    NSMutableArray *settingsSections = [NSMutableArray new];

    DBSettingsSection *userSection = [[DBSettingsSection alloc] init:DBSettingsSectionTypeUser];
    
    if ([[DBCitiesManager sharedInstance] cities].count > 1) {
        DBSettingsItem *item = [DBCitiesViewController settingsItem];
        [userSection.items addObject:item];
    }
    
    [userSection.items addObject:[DBProfileViewController settingsItem]];
    
    [settingsSections addObject:userSection];
    
    return settingsSections;
}

@end
