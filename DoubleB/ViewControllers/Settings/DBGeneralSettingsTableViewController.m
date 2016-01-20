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

- (void)loadAllSettingsItems {
    [self.settingsItems addObject:[DBProfileViewController settingsItem]];
    
    if ([[DBCitiesManager sharedInstance] cities]) {
        DBSettingsItem *item = [DBCitiesViewController settingsItem];
        [(DBCitiesViewController *)[item viewController] setDelegate:self];
        [self.settingsItems addObject:item];
    }
}

- (void)db_citiesViewControllerDidSelectCity:(DBUnifiedCity *)city {
    [DBCitiesManager selectCity:city];
    [[DBUnifiedAppManager sharedInstance] fetchMenu:nil];
    [[DBUnifiedAppManager sharedInstance] fetchVenues:nil];
}

@end
