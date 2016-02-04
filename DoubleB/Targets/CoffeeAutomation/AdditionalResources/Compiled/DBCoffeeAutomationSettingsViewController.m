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
@property (strong, nonatomic) NSMutableArray *settingsItems;
@end

@implementation DBCoffeeAutomationSettingsViewController

- (NSMutableArray<DBSettingsItemProtocol> *)settingsItems {
    NSMutableArray<DBSettingsItemProtocol> *settingsItems = [super settingsItems];
    
    [settingsItems insertObject:[DBApplicationSettingsViewController settingsItem] atIndex:0];
    
    return settingsItems;
}

@end
