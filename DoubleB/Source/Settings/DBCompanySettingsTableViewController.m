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

#import "ViewControllerManager.h"

@implementation DBCompanySettingsTableViewController

- (NSMutableArray *)settingsItems {
    NSMutableArray *settingsItems = [NSMutableArray new];
    
    if ([DBCompaniesManager sharedInstance].hasCompanies) {
        [settingsItems addObject:[[ViewControllerManager companiesViewController] settingsItem]];
    }
    
    [settingsItems addObject:[DBProfileViewController settingsItem]];
    [settingsItems addObject:[DBOrdersTableViewController settingsItem]];
    
    if ([[DBCompanyInfo sharedInstance] friendInvitationEnabled]) {
        [settingsItems addObject:[[ViewControllerManager shareFriendInvitationViewController] settingsItem]];
    }
    
    if ([[DBFriendGiftHelper sharedInstance] enabled]) {
        [settingsItems addObject:[DBFriendGiftViewController settingsItem]];
    }
    
    if ([[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCard] ||
        [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypePayPal]) {
        [settingsItems addObject:[DBPaymentViewController settingsItem]];
    }
    
    if ([[[OrderCoordinator sharedInstance] promoManager] walletEnabled]) {
        [settingsItems addObject:[OrderCoordinator settingsItem]];
        [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPersonalWalletBalanceUpdated selector:@selector(reload)];
    }
    
    [settingsItems addObject:[DBPromosListViewController settingsItem]];
    
    if ([CompanyNewsManager sharedManager].available) {
        [settingsItems addObject:[DBNewsHistoryTableViewController settingsItem]];
    }
    
    [settingsItems addObject:[DBCompanyInfoViewController settingsItem]];
    [settingsItems addObject:[DBDocumentsViewController settingsItem]];
    
    if ([[[DBCompanyInfo sharedInstance] promocodesIsEnabled] boolValue]) {
        [settingsItems addObject:[[ViewControllerManager promocodeViewController] settingsItem]];
    }
    
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
        [settingsItems addObject:[[ViewControllerManager subscriptionViewController] settingsItem]];
    }
    
    if ([[DBCustomViewManager sharedInstance] available]) {
        [settingsItems addObject:[DBCustomTableViewController settingsItem]];
    }
    
    return settingsItems;
}

@end
