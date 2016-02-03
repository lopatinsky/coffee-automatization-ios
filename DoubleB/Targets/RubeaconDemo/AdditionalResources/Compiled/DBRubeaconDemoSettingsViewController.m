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

- (NSMutableArray<DBSettingsItemProtocol> *)settingsItems {
    NSMutableArray<DBSettingsItemProtocol> *settingsItems = [super settingsItems];
    
    [settingsItems insertObject:[DBDemoLoginViewController settingsItem] atIndex:0];
    
    return settingsItems;
}

@end
