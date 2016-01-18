//
//  DBSettingsBaseTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBSettingsBaseTableViewController.h"
#import "DBSettingsCell.h"

#import "OrderCoordinator.h"

#import <MessageUI/MessageUI.h>


NSString *const kDBSettingsNotificationsEnabled = @"kDBSettingsNotificationsEnabled";

@interface DBSettingsBaseTableViewController ()

@property (nonatomic, strong) NSMutableArray *settingsItems;

@end

@implementation DBSettingsBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Профиль", nil)];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.rowHeight = 50;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:@"Settings_screen"];
    
    [self.tableView reloadData];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:SETTINGS_SCREEN];
    }
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload{
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
    
    NSDictionary *settingsItemInfo = self.settingsItems[indexPath.row];
    
    [cell.settingsImageView templateImageWithName:settingsItemInfo[@"image"]];
    
    cell.titleLabel.text = settingsItemInfo[@"title"];
    
    if([settingsItemInfo[@"name"] isEqualToString:@"profileVC"]){
        NSString *profileText = [DBClientInfo sharedInstance].clientName.value;
        cell.titleLabel.text = profileText && profileText.length ? profileText : NSLocalizedString(@"Профиль", nil);
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"personalWalletVC"]){
        NSString *profileText;
        if([OrderCoordinator sharedInstance].promoManager.walletBalance > 0){
            profileText = [NSString stringWithFormat:@"%@: %.1f", NSLocalizedString(@"Личный счет", nil), [OrderCoordinator sharedInstance].promoManager.walletBalance];
        } else {
            profileText = NSLocalizedString(@"Личный счет", nil);
        }
        
        cell.titleLabel.text = profileText;
    }
    
    cell.hasSwitch = NO;
    if([settingsItemInfo[@"name"] isEqualToString:@"notification"]){
        cell.hasSwitch = YES;
        cell.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kDBSettingsNotificationsEnabled];
        
        
        cell.delegate = self;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *settingsItemInfo;
    if(indexPath.row < [self.settingsItems count]){
        settingsItemInfo = self.settingsItems[indexPath.row];
    }
    
    NSString *event;
    
    if([settingsItemInfo[@"name"] isEqualToString:@"profileVC"]){
        event = @"profile_click";
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"ordersVC"]){
        event = @"history_click";
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"cardsVC"]){
        event = @"cards_click";
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"mailer"]){
        event = @"contact_us_click";
        [self presentMailViewControllerWithRecipients:nil callback:nil];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"aboutCompany"]){
        event = @"about_click";
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"shareVC"]) {
        [self presentViewController:settingsItemInfo[@"viewController"] animated:YES completion:nil];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"friendGiftVC"]) {
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"promosVC"]) {
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if ([settingsItemInfo[@"name"] isEqualToString:@"newsHistoryVC"]) {
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"personalWalletVC"]) {
        DBPersonalWalletView *view = [DBPersonalWalletView new];
        [view showOnView:self.navigationController.view];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"aboutPromoVC"]) {
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"documentsVC"]) {
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if ([settingsItemInfo[@"name"] isEqualToString:@"personalAccountVC"]) {
        event = @"wallet_click";
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if ([settingsItemInfo[@"name"] isEqualToString: @"companyInfoVC"]) {
        event = @"about_app_click";
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    if ([settingsItemInfo[@"name"] isEqualToString:@"companiesVC"]) {
        event = @"companies_click";
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    if ([settingsItemInfo[@"name"] isEqualToString:@"appPromoVC"]){
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    if ([settingsItemInfo[@"name"] isEqualToString:@"subscriptionVC"]){
        event = @"abonement_click";
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    [GANHelper analyzeEvent:event category:SETTINGS_SCREEN];
}

@end
