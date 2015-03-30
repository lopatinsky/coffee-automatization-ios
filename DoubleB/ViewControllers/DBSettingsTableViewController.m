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
#import "UIImageView+Extension.h"
#import "PersonalAccountViewController.h"

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
    DBCardsViewController *cardsVC = [DBCardsViewController new];
    cardsVC.screen = @"Cards_screen";
    [self.settingsItems addObject:@{@"name": @"cardsVC",
                                    @"title": NSLocalizedString(@"Карты", nil),
                                    @"image": @"card",
                                    @"viewController": cardsVC}];
    
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
        [GANHelper analyzeEvent:@"back_menu_click"
                       category:@"Settings_screen"];
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
                [GANHelper analyzeEvent:@"send_notifications" label:s.on?@"on":@"off" category:@"Settings_screen"];
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
    
    if([settingsItemInfo[@"name"] isEqualToString:@"profileVC"]){
        [GANHelper analyzeEvent:@"profile_click"
                          label:[NSString stringWithFormat:@"%@,%@", [DBClientInfo sharedInstance].clientName, [DBClientInfo sharedInstance].clientPhone]
                       category:@"Settings_screen"];
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"cardsVC"]){
        [GANHelper analyzeEvent:@"card_click"
                          label:[NSString stringWithFormat:@"%lu", (unsigned long) [IHSecureStore sharedInstance].cardCount]
                       category:@"Settings_screen"];
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"mailer"]){
        [GANHelper analyzeEvent:@"review_click"
                       category:@"Settings_screen"];
        [self presentMailViewControllerWithRecipients:nil callback:nil];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"shareVC"]){
        [GANHelper analyzeEvent:@"share_click"
                       category:@"Settings_screen"];
        [self shareAppPermission:nil];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"aboutPromoVC"]){
        [GANHelper analyzeEvent:@"about_promo_click"
                       category:@"Settings_screen"];
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"aboutVC"]){
        [GANHelper analyzeEvent:@"about_app_click"
                       category:@"Settings_screen"];
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if([settingsItemInfo[@"name"] isEqualToString:@"privacyPolicyVC"]){
        [GANHelper analyzeEvent:@"nda_click"
                       category:@"Settings_screen"];
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
    
    if ([settingsItemInfo[@"name"] isEqualToString:@"personalAccountVC"]) {
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
}

#pragma mark - MFMailComposer

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if(result == MFMailComposeResultSent){
        [GANHelper analyzeEvent:@"review_send" category:@"Review_screen"];
    }

    if(result == MFMailComposeResultCancelled || result == MFMailComposeResultSaved){
        [GANHelper analyzeEvent:@"review_cancel" category:@"Review_screen"];
    }

    if(result == MFMailComposeResultFailed){
        [GANHelper analyzeEvent:@"review_failed" category:@"Review_screen"];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
