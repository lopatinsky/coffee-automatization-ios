//
//  DBSettingsBaseTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBBaseSettingsTableViewController.h"
#import "DBSettingsCell.h"
#import "DBPersonalWalletView.h"

#import "OrderCoordinator.h"

#import <MessageUI/MessageUI.h>

NSString *const kDBSettingsNotificationsEnabled2 = @"kDBSettingsNotificationsEnabled";

@interface DBBaseSettingsTableViewController ()
@property (nonatomic, strong) NSMutableArray<DBSettingsItemProtocol> *items;
@end

@implementation DBBaseSettingsTableViewController

- (instancetype)init {
    if (self = [super init]) {
        _items = [NSMutableArray<DBSettingsItemProtocol> new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Профиль", nil)];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.rowHeight = 50;
    
    self.items = [self settingsItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:@"Settings_screen"];
    
    [self.tableView reloadData];
}

- (NSMutableArray *)settingsItems {
    return nil;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:SETTINGS_SCREEN];
    }
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload {
    _items = [self settingsItems];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBSettingsCell"];
    
    if (!cell) {
        cell = [DBSettingsCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.hasIcon = YES;
    }
    
    id<DBSettingsItemProtocol> settingsItemInfo = self.settingsItems[indexPath.row];
    [cell.settingsImageView templateImageWithName:[settingsItemInfo iconName]];
    [cell.titleLabel setText:[settingsItemInfo title]];
    cell.hasSwitch = NO;
    
    if ([settingsItemInfo reachTitle]) {
        [cell.titleLabel setText:[settingsItemInfo reachTitle]];
    }
    
    if ([settingsItemInfo params]) {
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBSettingsItem *item = self.items[indexPath.row];
    NSString *event = [item eventLabel];
    [GANHelper analyzeEvent:event category:SETTINGS_SCREEN];
    
    if (item.block) {
        item.block();
    } else {
        DBSettingsItemNavigation navigationType = [item navigationType];
        switch (navigationType) {
            case DBSettingsItemNavigationPresent:
                [self presentViewController:[self.settingsItems[indexPath.row] viewController] animated:YES completion:nil];
                break;
            case DBSettingsItemNavigationPush:
                [self.navigationController pushViewController:[self.settingsItems[indexPath.row] viewController] animated:YES];
                break;
            case DBSettingsItemNavigationShowView:
                // TODO: protocol
                [(DBPersonalWalletView *)[self.settingsItems[indexPath.row] view] showOnView:self.navigationController.view];
                break;
            default:
                break;
        }
    }
}

@end
