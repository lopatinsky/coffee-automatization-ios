//
//  DBRubeaconDemoSettingsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBRubeaconDemoSettingsViewController.h"
#import "AppDelegate.h"
#import "DBDemoLoginViewController.h"
#import "DBAPIClient.h"

@interface DBRubeaconDemoSettingsViewController ()
@property (strong, nonatomic) NSMutableArray *settingsItems;
@end

@implementation DBRubeaconDemoSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Application settings item
    [self.settingsItems insertObject:@{@"name": @"logoutDemo",
                                       @"title": @"Выйти из демо",
                                       @"image": @"none"}
                             atIndex:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSDictionary *settingsItemInfo;
    if(indexPath.row < [self.settingsItems count]){
        settingsItemInfo = self.settingsItems[indexPath.row];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"logoutDemo"]){
        [UIView transitionWithView:[(AppDelegate *)[[UIApplication sharedApplication] delegate] window]
                          duration:0.5
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            [[DBAPIClient sharedClient] disableCompanyHeader];
                            [(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController = [DBDemoLoginViewController new];
                        }
                        completion:nil];
    }
}


@end
