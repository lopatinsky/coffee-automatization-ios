//
//  DBSettingsTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 01/08/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBSettingsTableViewController.h"
#import "DBHTMLViewController.h"
#import "DBProfileViewController.h"
#import "DBCardsViewController.h"
#import "DBAboutPromoViewController.h"
#import "DBMastercardPromo.h"
#import "IHSecureStore.h"
#import "DBBeaconObserver.h"
#import "DBClientInfo.h"
#import "UIViewController+ShareExtension.h"
#import "UIViewController+DBMessage.h"
#import "PersonalAccountViewController.h"
#import "DBCompanyInfoViewController.h"
#import "IHPaymentManager.h"
#import "Order.h"

#import <MessageUI/MessageUI.h>
#import <BlocksKit/UIControl+BlocksKit.h>

#import "DBSharePermissionViewController.h"

NSString *const kDBSettingsNotificationsEnabled = @"kDBSettingsNotificationsEnabled";

@interface DBSettingsTableViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *tableCell;
@property (strong, nonatomic) NSMutableArray *settingsItems;

@end

@implementation DBSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Настройки", nil);
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
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
    
    // Cards item
    NSArray *availablePaymentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsAvailablePaymentTypes];
    if([availablePaymentTypes containsObject:@(PaymentTypeCard)]){
        DBCardsViewController *cardsVC = [DBCardsViewController new];
        cardsVC.screen = @"Cards_screen";
        [self.settingsItems addObject:@{@"name": @"cardsVC",
                                        @"title": NSLocalizedString(@"Карты", nil),
                                        @"image": @"card",
                                        @"viewController": cardsVC}];
    }
    
    // Personal account item
    PersonalAccountViewController *personalAccountVC = [PersonalAccountViewController new];
    [self.settingsItems addObject:@{@"name": @"personalAccountVC",
                                    @"title": NSLocalizedString(@"Личный счет", nil),
                                    @"image": @"payment",
                                    @"viewController": personalAccountVC}];
    
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
    
//    if([[DBMastercardPromo sharedInstance] promoIsAvailable]){
//        // About promo item
//        DBAboutPromoViewController *aboutPromoVC = [DBAboutPromoViewController new];
//        [self.settingsItems addObject:@{@"name": @"aboutPromoVC",
//                                        @"title": NSLocalizedString(@"Об акции", nil),
//                                        @"image": @"about_promo",
//                                        @"viewController": aboutPromoVC}];
//    }
    
//    // About app item
//    DBHTMLViewController *aboutVC = [DBHTMLViewController new];
//    aboutVC.title = NSLocalizedString(@"О приложении", nil);
//    aboutVC.screen = @"About_app_screen";
//    aboutVC.url = [NSURL URLWithString:@"http://empatika-doubleb.appspot.com/docs/about.html"];
//    [self.settingsItems addObject:@{@"name": @"aboutVC",
//                                    @"title": NSLocalizedString(@"О приложении", nil),
//                                    @"image": @"about",
//                                    @"viewController": aboutVC}];
    
//    // Privacy policy item
//    DBHTMLViewController *privacyPolicyVC = [DBHTMLViewController new];
//    privacyPolicyVC.title = NSLocalizedString(@"Политика конфиденциальности", nil);
//    privacyPolicyVC.url = [NSURL URLWithString:@"http://empatika-doubleb.appspot.com/docs/nda.html"];
//    privacyPolicyVC.screen = @"NDA_screen";
//    [self.settingsItems addObject:@{@"name": @"privacyPolicyVC",
//                                    @"title": NSLocalizedString(@"Политика конфиденциальности", nil),
//                                    @"image": @"confidence",
//                                    @"viewController": privacyPolicyVC}];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    
    if (!cell) {
        [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil];
        cell = self.tableCell;
        self.tableCell = nil;
    }
    
    UIImageView *imageViewIcon = (UIImageView *)[cell viewWithTag:1];
    UILabel *labelTitle = (UILabel *)[cell viewWithTag:2];
    UISwitch *switcher = (UISwitch *)[cell viewWithTag:3];
    UIImageView *imageViewArrow = (UIImageView *)[cell viewWithTag:4];
    [imageViewArrow templateImageWithName:@"arrow"];
    
    NSDictionary *settingsItemInfo = self.settingsItems[indexPath.row];
    
//    imageViewIcon.image = [UIImage imageNamed:settingsItemInfo[@"image"]];
    [imageViewIcon templateImageWithName:settingsItemInfo[@"image"]];
    
    if([settingsItemInfo[@"name"] isEqualToString:@"profileVC"]){
        NSString *profileText = [DBClientInfo sharedInstance].clientName;
        labelTitle.text = profileText && profileText.length ? profileText : NSLocalizedString(@"Профиль", nil);
    } else {
        labelTitle.text = settingsItemInfo[@"title"];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"notification"]){
        switcher.hidden = NO;
        switcher.onTintColor = [UIColor db_defaultColor];
        if (![switcher bk_hasEventHandlersForControlEvents:UIControlEventValueChanged]) {
            [switcher bk_addEventHandler:^(id sender) {
                UISwitch *s = sender;
                [GANHelper analyzeEvent:@"notification_switched" label:(s.on ? @"YES":@"NO") category:SETTINGS_SCREEN];
                BOOL enabled = ![[NSUserDefaults standardUserDefaults] boolForKey:kDBSettingsNotificationsEnabled];
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kDBSettingsNotificationsEnabled];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (enabled) {
                    [DBBeaconObserver createBeaconObserver];
                } else {
                    [DBBeaconObserver stopMonitoringRegions];
                }
            } forControlEvents:UIControlEventValueChanged];
        }
        switcher.on = [[NSUserDefaults standardUserDefaults] boolForKey:kDBSettingsNotificationsEnabled];
    } else {
        switcher.hidden = YES;
    }
    
    imageViewArrow.hidden = !switcher.hidden;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *settingsItemInfo = self.settingsItems[indexPath.row];
    
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
    
    if([settingsItemInfo[@"name"] isEqualToString:@"aboutPromoVC"]){
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"aboutVC"]){
        
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"privacyPolicyVC"]){
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

@end
