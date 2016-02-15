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
@property (nonatomic, strong) NSMutableArray *sections;
@end

@implementation DBBaseSettingsTableViewController

- (instancetype)init {
    if (self = [super init]) {
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
    self.tableView.rowHeight = 45;
    
    self.sections = [self settingsSections];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:@"Settings_screen"];
    
    [self.tableView reloadData];
}

- (NSMutableArray *)settingsSections {
    return [NSMutableArray new];
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
    _sections = [self settingsSections];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DBSettingsSection *settingsSection = _sections[section];
    return settingsSection.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBSettingsCell"];
    
    if (!cell) {
        cell = [DBSettingsCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.hasIcon = YES;
    }
    
    DBSettingsSection *settingsSection = _sections[indexPath.section];
    id<DBSettingsItemProtocol> settingsItemInfo = settingsSection.items[indexPath.row];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1f;
    } else {
        return 30.f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBSettingsSection *settingsSection = _sections[indexPath.section];
    DBSettingsItem *item = settingsSection.items[indexPath.row];
    
    NSString *event = [item eventLabel];
    [GANHelper analyzeEvent:event category:SETTINGS_SCREEN];
    
    if (item.block) {
        item.block(self);
    } else {
        DBSettingsItemNavigation navigationType = [item navigationType];
        switch (navigationType) {
            case DBSettingsItemNavigationPresent:
                [self presentViewController:[item viewController] animated:YES completion:nil];
                break;
            case DBSettingsItemNavigationPush:
                [self.navigationController pushViewController:[item viewController] animated:YES];
                break;
            case DBSettingsItemNavigationShowView:
                // TODO: protocol
                [(DBPersonalWalletView *)[item view] showOnView:self.navigationController.view];
                break;
            default:
                break;
        }
    }
}

@end
