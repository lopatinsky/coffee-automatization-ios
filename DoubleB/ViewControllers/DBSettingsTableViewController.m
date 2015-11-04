//
//  DBSettingsTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 01/08/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBSettingsTableViewController.h"
#import "DBSettingsCell.h"
#import "DBDocumentsViewController.h"
#import "DBProfileViewController.h"
#import "DBPaymentViewController.h"
#import "DBPromosListViewController.h"
#import "IHSecureStore.h"
//#import "DBBeaconObserver.h"
#import "DBClientInfo.h"
#import "DBCompanyInfoViewController.h"
#import "DBCompaniesViewController.h"
#import "IHPaymentManager.h"
#import "OrderCoordinator.h"
#import "DBPayPalManager.h"
#import "DBPersonalWalletView.h"
#import "DBCompaniesManager.h"
#import "DBFriendGiftHelper.h"
#import "DBFriendGiftViewController.h"
#import "DBOrdersTableViewController.h"


#import "UIViewController+ShareExtension.h"
#import "UIViewController+DBMessage.h"

#import <MessageUI/MessageUI.h>
#import <BlocksKit/UIControl+BlocksKit.h>

#import "DBSharePermissionViewController.h"

NSString *const kDBSettingsNotificationsEnabled = @"kDBSettingsNotificationsEnabled";

@interface DBSettingsTableViewController () <MFMailComposeViewControllerDelegate, DBSettingsCellDelegate, DBPersonalWalletViewDelegate>
@property (strong, nonatomic) NSMutableArray *settingsItems;

@end

@implementation DBSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Настройки", nil);
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.rowHeight = 50;
    
    self.settingsItems = [[NSMutableArray alloc] init];
    
    // Companies item
    if([DBCompaniesManager sharedInstance].hasCompanies){
        DBCompaniesViewController *companiesVC = [DBCompaniesViewController new];
        companiesVC.mode = DBCompaniesViewControllerModeChangeCompany;
        [self.settingsItems addObject:@{@"name": @"companiesVC",
                                           @"title": NSLocalizedString(@"Список ресторанов", nil),
                                           @"image": @"venue_gray",
                                           @"viewController": companiesVC
                                           }];
    }
    
    // Profile item
    DBProfileViewController *profileVC = [DBProfileViewController new];
    profileVC.analyticsScreen = @"Profile_screen";
    [self.settingsItems addObject:@{@"name": @"profileVC",
                                    @"image": @"profile_icon_active",
                                    @"viewController": profileVC}];
    
    // Profile item
    DBOrdersTableViewController *ordersVC = [DBOrdersTableViewController new];
    [self.settingsItems addObject:@{@"name": @"ordersVC",
                                    @"title": NSLocalizedString(@"Заказы", nil),
                                    @"image": @"history_icon",
                                    @"viewController": ordersVC}];
    
    // Share friends item
    if ([[DBCompanyInfo sharedInstance] friendInvitationEnabled]) {
        [self.settingsItems addObject:@{@"name": @"shareVC",
                                        @"title": NSLocalizedString(@"Рассказать друзьям", nil),
                                        @"image": @"share_icon",
                                        @"viewController": [ViewControllerManager shareFriendInvitationViewController]}];
    }
    
    // Friend gift item
    if([DBFriendGiftHelper sharedInstance].enabled) {
        [self.settingsItems addObject:@{@"name": @"friendGiftVC",
                                        @"title": NSLocalizedString(@"Подарок другу", nil),
                                        @"image": @"gift_icon",
                                        @"viewController": [DBFriendGiftViewController new]}];
    }
    
    // Payment item
    // Cards item
    if([[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCard] || [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCash]){
        DBPaymentViewController *paymentVC = [DBPaymentViewController new];
        paymentVC.mode = DBPaymentViewControllerModeSettings;
        
        [self.settingsItems addObject:@{@"name": @"cardsVC",
                                        @"title": NSLocalizedString(@"Оплата", nil),
                                        @"image": @"card",
                                        @"viewController": paymentVC}];
    }
    
    // Personal wallet item
    if([OrderCoordinator sharedInstance].promoManager.walletEnabled){
        [self.settingsItems addObject:@{@"name": @"personalWalletVC",
                                        @"image": @"wallet_icon_active"}];
        [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPersonalWalletBalanceUpdated selector:@selector(reload)];
    }
    
    // Promotion list item
    DBPromosListViewController *promosVC = [DBPromosListViewController new];
    [self.settingsItems addObject:@{@"name": @"promosVC",
                                    @"title": NSLocalizedString(@"Список акций", nil),
                                    @"image": @"promos_icon",
                                    @"viewController": promosVC}];
    
    // Contact us item
    [self.settingsItems addObject:@{@"name": @"mailer",
                                    @"title": NSLocalizedString(@"Написать нам", nil),
                                    @"image": @"feedback"}];
    
    

    
    // Documents item
    DBDocumentsViewController *documentsVC = [DBDocumentsViewController new];
    [self.settingsItems addObject:@{@"name": @"documentsVC",
                                    @"title": NSLocalizedString(@"Справка", nil),
                                    @"image": @"about",
                                    @"viewController": documentsVC}];
    
    
    // Notifications item
//    [self.settingsItems addObject:@{@"name": @"notification",
//                                    @"title": NSLocalizedString(@"Присылать уведомления", nil),
//                                    @"image": @"alerts.png"}];
    
    if ([[[DBCompanyInfo sharedInstance] promocodesIsEnabled] boolValue]) {
        [self.settingsItems addObject:@{@"name": @"appPromoVC",
                                        @"title": NSLocalizedString(@"Промокоды", nil),
                                        @"image": @"promocodes_icon",
                                        @"viewController": [ViewControllerManager promocodeViewController]}];
    }
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

- (void)dealloc{
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
    
    if([settingsItemInfo[@"name"] isEqualToString:@"shareVC"]) {
        [self presentViewController:settingsItemInfo[@"viewController"] animated:YES completion:nil];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"friendGiftVC"]) {
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"promosVC"]) {
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
    
    [GANHelper analyzeEvent:event category:SETTINGS_SCREEN];
}

#pragma mark - MFMailComposer

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if(result == MFMailComposeResultSent){
    }

    if(result == MFMailComposeResultCancelled || result == MFMailComposeResultSaved){
    }

    if(result == MFMailComposeResultFailed){
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - DBSettingsCellDelegate

//- (void)db_settingsCell:(DBSettingsCell *)cell didChangeSwitchValue:(BOOL)switchValue{
//    [GANHelper analyzeEvent:@"notification_switched" label:(switchValue ? @"YES" : @"NO") category:SETTINGS_SCREEN];
//    BOOL enabled = ![[NSUserDefaults standardUserDefaults] boolForKey:kDBSettingsNotificationsEnabled];
//    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kDBSettingsNotificationsEnabled];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    if (enabled) {
//        [DBBeaconObserver createBeaconObserver];
//    } else {
//        [DBBeaconObserver stopMonitoringRegions];
//    }
//}

#pragma mark - DBPersonalWalletViewDelegate

- (void)db_personalWalletView:(DBPersonalWalletView *)view didUpdateBalance:(double)balance{
    [self.tableView reloadData];
}

@end
