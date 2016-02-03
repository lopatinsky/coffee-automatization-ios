//
//  DBCustomTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBCustomTableViewController.h"

#import "DBCustomViewManager.h"
#import "DBCustomItem.h"
#import "DBWebViewController.h"
#import "DBSettingsCell.h"

#import "GANHelper.h"

@interface DBCustomTableViewController ()

@property (strong, nonatomic) NSMutableArray *items;

@end

@implementation DBCustomTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self db_setTitle:NSLocalizedString(@"Другое", nil)];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.rowHeight = 50;
    
    self.items = [NSMutableArray new];
    for (DBCustomItem *item in [[DBCustomViewManager sharedInstance] items]) {
        DBWebViewController *webVC = [DBWebViewController new];
        webVC.webViewTitle = item.title;
        webVC.urlString = item.urlString;
        [self.items addObject:@{@"title": item.title, @"viewController": webVC}];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GANHelper analyzeScreen:OTHER_SCREEN];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBSettingsCell"];
    
    if (!cell) {
        cell = [DBSettingsCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.hasIcon = NO;
        cell.hasSwitch = NO;
    }
    
    NSDictionary *itemDict = self.items[indexPath.row];
    cell.titleLabel.text = itemDict[@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemDict = self.items[indexPath.row];
    [self.navigationController pushViewController:itemDict[@"viewController"] animated:YES];
}

#pragma mark - DBSettingsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBCustomTableViewController *customVC = [DBCustomTableViewController new];
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    
    settingsItem.name = @"otherVC";
    settingsItem.title = NSLocalizedString(@"Другое", nil);
    settingsItem.iconName = @"ic_launch";
    settingsItem.viewController = customVC;
    settingsItem.reachTitle = nil;
    settingsItem.eventLabel = @"other_click";
    settingsItem.navigationType = DBSettingsItemNavigationPush;
    
    return settingsItem;
}

@end
