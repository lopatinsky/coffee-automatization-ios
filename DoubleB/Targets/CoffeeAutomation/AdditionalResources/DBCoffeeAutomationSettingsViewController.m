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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Application settings item
    DBApplicationSettingsViewController *applicationSettingsVC = [DBApplicationSettingsViewController new];
    [self.settingsItems insertObject:@{@"name": @"appSetterVC",
                                       @"title": @"Выбрать приложение",
                                       @"image": @"none",
                                       @"viewController": applicationSettingsVC}
                             atIndex:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSDictionary *settingsItemInfo;
    if(indexPath.row < [self.settingsItems count]){
        settingsItemInfo = self.settingsItems[indexPath.row];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"appSetterVC"]){
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
}

@end
