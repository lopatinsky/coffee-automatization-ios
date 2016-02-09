//
//  DBCompanySettingsTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBCompanySettingsTableViewController.h"

#import "DBCompaniesManager.h"
#import "DBProfileViewController.h"
#import "DBOrdersTableViewController.h"
#import "DBCompanyInfo.h"
#import "DBShareHelper.h"
#import "DBFriendGiftHelper.h"
#import "DBFriendGiftViewController.h"
#import "IHPaymentManager.h"
#import "DBPaymentViewController.h"
#import "OrderCoordinator.h"
#import "DBPromosListViewController.h"
#import "CompanyNewsManager.h"
#import "DBNewsHistoryTableViewController.h"
#import "DBCompanyInfoViewController.h"
#import "DBDocumentsViewController.h"
#import "DBSubscriptionManager.h"
#import "DBCustomViewManager.h"
#import "DBCustomTableViewController.h"
#import "DBCitiesManager.h"
#import "DBCitiesViewController.h"
#import "DBVenuesViewController.h"

#import "ViewControllerManager.h"

@implementation DBCompanySettingsTableViewController

- (NSMutableArray<DBSettingsItemProtocol> *)settingsItems {
    NSMutableArray<DBSettingsItemProtocol> *settingsItems = [NSMutableArray<DBSettingsItemProtocol> new];
    
    // Cities
    if ([[DBCitiesManager sharedInstance] cities].count > 1) {
        DBSettingsItem *item = [DBCitiesViewController settingsItem];
        [settingsItems addObject:item];
    }
    
    // Companies
    if ([DBCompaniesManager sharedInstance].hasCompanies) {
        [settingsItems addObject:[[ViewControllerManager companiesViewController] settingsItem]];
    }
    
    // Profile
    [settingsItems addObject:[DBProfileViewController settingsItem]];
    
    // Orders
    [settingsItems addObject:[DBOrdersTableViewController settingsItem]];
    
    // Venues item
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdInRestaurant] || [[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdTakeaway]) {
        [settingsItems addObject:[DBVenuesViewController settingsItem]];
    }
    
    // Share
    if ([DBShareHelper sharedInstance].enabled) {
        [settingsItems addObject:[[ViewControllerManager shareFriendInvitationViewController] settingsItem:self]];
    }
    
    // Friend gift
    if ([[DBFriendGiftHelper sharedInstance] enabled]) {
        [settingsItems addObject:[DBFriendGiftViewController settingsItem]];
    }
    
    // Payment
    if ([[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCard] ||
        [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypePayPal]) {
        [settingsItems addObject:[DBPaymentViewController settingsItem]];
    }
    
    // Personal wallet
    if ([[[OrderCoordinator sharedInstance] promoManager] walletEnabled]) {
        [settingsItems addObject:[OrderCoordinator settingsItem]];
        [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPersonalWalletBalanceUpdated selector:@selector(reload)];
    }
    
    // Promos
    [settingsItems addObject:[DBPromosListViewController settingsItem]];
    
    // News
    if ([CompanyNewsManager sharedManager].available) {
        [settingsItems addObject:[DBNewsHistoryTableViewController settingsItem]];
    }
    
    // CompanyInfo
    [settingsItems addObject:[DBCompanyInfoViewController settingsItem]];
    
    // Documents
    [settingsItems addObject:[DBDocumentsViewController settingsItem]];
    
    // Promocodes
    if ([[[DBCompanyInfo sharedInstance] promocodesIsEnabled] boolValue]) {
        [settingsItems addObject:[[ViewControllerManager promocodeViewController] settingsItem]];
    }
    
    // Subscription
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
        [settingsItems addObject:[[ViewControllerManager subscriptionViewController] settingsItem]];
    }
    
    // Custom information
    if ([[DBCustomViewManager sharedInstance] available]) {
        [settingsItems addObject:[DBCustomTableViewController settingsItem]];
    }
    
    return settingsItems;
}

@end
