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

- (NSMutableArray *)settingsItems {
    NSMutableArray *settingsItems = [NSMutableArray new];
    
    if ([[DBCitiesManager sharedInstance] cities].count > 1) {
        DBSettingsItem *item = [DBCitiesViewController settingsItem];
        [settingsItems addObject:item];
    }
    
    [settingsItems addObject:[DBProfileViewController settingsItem]];
    
    return settingsItems;
}

@end
