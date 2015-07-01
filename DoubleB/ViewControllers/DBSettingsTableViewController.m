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
#import "DBCardsViewController.h"
#import "DBPromosListViewController.h"
#import "IHSecureStore.h"
#import "DBBeaconObserver.h"
#import "DBClientInfo.h"
#import "DBCompanyInfoViewController.h"
#import "IHPaymentManager.h"
#import "DBPromoManager.h"
#import "Order.h"
#import "Compatibility.h"
#import "DBPayPalManager.h"
#import "DBPersonalWalletView.h"

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
    
    // Profile item
    DBProfileViewController *profileVC = [DBProfileViewController new];
    profileVC.screen = @"Profile_screen";
    [self.settingsItems addObject:@{@"name": @"profileVC",
                                    @"image": @"profile",
                                    @"viewController": profileVC}];
    
    // Payment item
    // Cards item
    NSArray *availablePaymentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsAvailablePaymentTypes];
    if([availablePaymentTypes containsObject:@(PaymentTypeCard)] || [availablePaymentTypes containsObject:@(PaymentTypePayPal)]){
        DBCardsViewController *cardsVC = [DBCardsViewController new];
        cardsVC.screen = @"Cards_screen";
        
        NSString *title = NSLocalizedString(@"Карты", nil);
        
        // PayPal item
        if([availablePaymentTypes containsObject:@(PaymentTypePayPal)]){
            title = NSLocalizedString(@"Электронные платежи", nil);
        }
        
        [self.settingsItems addObject:@{@"name": @"cardsVC",
                                        @"title": title,
                                        @"image": @"card",
                                        @"viewController": cardsVC}];
    }

    
    // Promotion list item
    DBPromosListViewController *promosVC = [DBPromosListViewController new];
    [self.settingsItems addObject:@{@"name": @"promosVC",
                                    @"title": NSLocalizedString(@"Список акций", nil),
                                    @"image": @"menu_icon",
                                    @"viewController": promosVC}];
    
    // Personal wallet item
    if([DBPromoManager sharedManager].walletEnabled){
        [self.settingsItems addObject:@{@"name": @"personalWalletVC",
                                        @"image": @"payment"}];
    }
    
    // Contact us item
    [self.settingsItems addObject:@{@"name": @"mailer",
                                    @"title": NSLocalizedString(@"Написать нам", nil),
                                    @"image": @"feedback"}];
    
    // Company info
//    DBCompanyInfoViewController *companyInfoVC = [DBCompanyInfoViewController new];
//    [self.settingsItems addObject:@{@"name": @"companyInfoVC",
//                                   @"title": NSLocalizedString(@"О компании", nil),
//                                   @"image": @"",
//                                   @"viewController": companyInfoVC}];
    
//    // Share friends item
//    [self.settingsItems addObject:@{@"name": @"shareVC",
//                                    @"title": NSLocalizedString(@"Рассказать друзьям", nil),
//                                    @"image": @"share_icon"}];

    
    // Documents item
    DBDocumentsViewController *documentsVC = [DBDocumentsViewController new];
    [self.settingsItems addObject:@{@"name": @"documentsVC",
                                    @"title": NSLocalizedString(@"Справка", nil),
                                    @"image": @"about",
                                    @"viewController": documentsVC}];
    
    
    // Notifications item
    [self.settingsItems addObject:@{@"name": @"notification",
                                    @"title": NSLocalizedString(@"Присылать уведомления", nil),
                                    @"image": @"alerts.png"}];
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
        NSString *profileText = [DBClientInfo sharedInstance].clientName;
        cell.titleLabel.text = profileText && profileText.length ? profileText : NSLocalizedString(@"Профиль", nil);
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"personalWalletVC"]){
        NSString *profileText;
        if([DBPromoManager sharedManager].walletBalance > 0){
            profileText = [NSString stringWithFormat:@"%@: %.1f", NSLocalizedString(@"Личный счет", nil), [DBPromoManager sharedManager].walletBalance];
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
    
    if([settingsItemInfo[@"name"] isEqualToString:@"cardsVC"]){
        event = @"cards_click";
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"mailer"]){
        event = @"contact_us_click";
        [self presentMailViewControllerWithRecipients:nil callback:nil];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"shareVC"]){
        [self shareAppPermission:nil];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"promosVC"]){
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"personalWalletVC"]){
        DBPersonalWalletView *view = [DBPersonalWalletView new];
        [view showOnView:self.navigationController.view];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"aboutPromoVC"]){
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"documentsVC"]){
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

- (void)db_settingsCell:(DBSettingsCell *)cell didChangeSwitchValue:(BOOL)switchValue{
    [GANHelper analyzeEvent:@"notification_switched" label:(switchValue ? @"YES" : @"NO") category:SETTINGS_SCREEN];
    BOOL enabled = ![[NSUserDefaults standardUserDefaults] boolForKey:kDBSettingsNotificationsEnabled];
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kDBSettingsNotificationsEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (enabled) {
        [DBBeaconObserver createBeaconObserver];
    } else {
        [DBBeaconObserver stopMonitoringRegions];
    }
}

#pragma mark - DBPersonalWalletViewDelegate

- (void)db_personalWalletView:(DBPersonalWalletView *)view didUpdateBalance:(double)balance{
    [self.tableView reloadData];
}

@end
