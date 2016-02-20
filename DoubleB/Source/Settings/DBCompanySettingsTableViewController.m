//
//  DBCompanySettingsTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBCompanySettingsTableViewController.h"

#import "DBCitiesManager.h"
#import "DBCitiesViewController.h"

#import "ViewControllerManager.h"
#import "DBCompanyInfo.h"
#import "DBCompaniesManager.h"
#import "DBProfileViewController.h"
#import "DBOrdersTableViewController.h"
#import "DBVenuesViewController.h"
#import "DBCompanyInfoViewController.h"
#import "DBDocumentsViewController.h"

#import "DBShareHelper.h"
#import "DBFriendGiftHelper.h"
#import "DBFriendGiftViewController.h"

#import "IHPaymentManager.h"
#import "DBPaymentViewController.h"

#import "OrderCoordinator.h"
#import "DBPromosListViewController.h"

#import "CompanyNewsManager.h"
#import "DBNewsHistoryTableViewController.h"

#import "DBSubscriptionManager.h"

#import "DBCustomViewManager.h"
#import "DBCustomTableViewController.h"
#import "DBCitiesManager.h"
#import "DBCitiesViewController.h"
#import "DBVenuesViewController.h"
#import "DBUnifiedMenuTableViewController.h"

#import "DBPlatiusQRViewController.h"
#import "DBPlatiusManager.h"


@implementation DBCompanySettingsTableViewController

- (NSMutableArray *)settingsSections {
    NSMutableArray *settingsSections = [NSMutableArray new];
    
    
    //
    // Company section
    //
    DBSettingsSection *companySection = [[DBSettingsSection alloc] init:DBSettingsSectionTypeCompany];
    
    // Cities
    if (![[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"coffeetogo"] &&
        [[DBCitiesManager sharedInstance] cities].count > 1) {
        DBSettingsItem *item = [DBCitiesViewController settingsItem];
        [companySection.items addObject:item];
    }
    
    // Companies
    if (![[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"coffeetogo"] &&
         [DBCompaniesManager sharedInstance].hasCompanies) {
        [companySection.items addObject:[[ViewControllerManager companiesViewController] settingsItem]];
    }
    
    // Unified app
    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"coffeetogo"]) {
        [companySection.items addObject:[DBUnifiedMenuTableViewController settingsItem]];
    }
    
    if (companySection.items.count > 0) {
        [settingsSections addObject:companySection];
    }
    
    
    //
    // User section
    //
    DBSettingsSection *userSection = [[DBSettingsSection alloc] init:DBSettingsSectionTypeUser];
    
    // Profile
    [userSection.items addObject:[DBProfileViewController settingsItem]];
    
    // Orders
    [userSection.items addObject:[DBOrdersTableViewController settingsItem]];
    
    // Payment
    if ([[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCard] ||
        [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypePayPal]) {
        [userSection.items addObject:[DBPaymentViewController settingsItem]];
    }
    
    // Venues item
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdInRestaurant] || [[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdTakeaway]) {
        [userSection.items addObject:[DBVenuesViewController settingsItem]];
    }
    
    if (userSection.items.count > 0) {
        [settingsSections addObject:userSection];
    }
    
    
    //
    // Loyalty section
    //
    DBSettingsSection *loyaltySection = [[DBSettingsSection alloc] init:DBSettingsSectionTypeLoyalty];
    
    // Share
    if ([DBShareHelper sharedInstance].enabled) {
        [loyaltySection.items addObject:[[ViewControllerManager shareFriendInvitationViewController] settingsItem:self]];
    }
    
    // Friend gift
    if ([[DBFriendGiftHelper sharedInstance] enabled]) {
        [loyaltySection.items addObject:[DBFriendGiftViewController settingsItem]];
    }
    
    // Personal wallet
    if ([[[OrderCoordinator sharedInstance] promoManager] walletEnabled]) {
        [loyaltySection.items addObject:[OrderCoordinator settingsItem]];
        [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPersonalWalletBalanceUpdated selector:@selector(reload)];
    }
    
    // Subscription
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
        [loyaltySection.items addObject:[[ViewControllerManager subscriptionViewController] settingsItem]];
    }
    
    // Platius barcode
    if ([DBPlatiusManager sharedInstance].enabled) {
        [loyaltySection.items addObject:[DBPlatiusQRViewController settingsItem]];
    }
    
    // Promos
    [loyaltySection.items addObject:[DBPromosListViewController settingsItem]];
    
    // Promocodes
    if ([[[DBCompanyInfo sharedInstance] promocodesIsEnabled] boolValue]) {
        [loyaltySection.items addObject:[[ViewControllerManager promocodeViewController] settingsItem]];
    }
    
    // News
    if ([CompanyNewsManager sharedManager].available) {
        [loyaltySection.items addObject:[DBNewsHistoryTableViewController settingsItem]];
    }
    
    if (loyaltySection.items.count > 0) {
        [settingsSections addObject:loyaltySection];
    }
    
    
    //
    // App section
    //
    DBSettingsSection *appSection = [[DBSettingsSection alloc] init:DBSettingsSectionTypeApp];
    
    // CompanyInfo
    [appSection.items addObject:[DBCompanyInfoViewController settingsItem]];
    
    // Documents
    [appSection.items addObject:[DBDocumentsViewController settingsItem]];
    
    // Custom information
    if ([[DBCustomViewManager sharedInstance] available]) {
        [appSection.items addObject:[DBCustomTableViewController settingsItem]];
    }
    
    if (appSection.items.count > 0) {
        [settingsSections addObject:appSection];
    }
    
    
    return settingsSections;
}

@end
