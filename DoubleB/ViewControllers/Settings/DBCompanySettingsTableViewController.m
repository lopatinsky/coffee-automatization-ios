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
#import "DBNewsHistoryTableViewController.h"
#import "DBCompanyInfoViewController.h"
#import "DBDocumentsViewController.h"
#import "DBSubscriptionManager.h"

#import "ViewControllerManager.h"

@implementation DBCompanySettingsTableViewController

- (void)loadAllSettingsItems {
    if ([DBCompaniesManager sharedInstance].hasCompanies) {
        [self.settingsItems addObject:[[ViewControllerManager companiesViewController] settingsItem]];
    }
    
    [self.settingsItems addObject:[DBProfileViewController settingsItem]];
    [self.settingsItems addObject:[DBOrdersTableViewController settingsItem]];
    
    if ([[DBCompanyInfo sharedInstance] friendInvitationEnabled]) {
        [self.settingsItems addObject:[[ViewControllerManager shareFriendInvitationViewController] settingsItem]];
    }
    
    if ([[DBFriendGiftHelper sharedInstance] enabled]) {
        [self.settingsItems addObject:[DBFriendGiftViewController settingsItem]];
    }
    
    if ([[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCard] ||
        [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypePayPal]) {
        [self.settingsItems addObject:[DBPaymentViewController settingsItem]];
    }
    
    if ([[[OrderCoordinator sharedInstance] promoManager] walletEnabled]) {
        [self.settingsItems addObject:[OrderCoordinator settingsItem]];
        [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPersonalWalletBalanceUpdated selector:@selector(reload)];
    }
    
    [self.settingsItems addObject:[DBPromosListViewController settingsItem]];
    [self.settingsItems addObject:[DBNewsHistoryTableViewController settingsItem]];
    [self.settingsItems addObject:[DBCompanyInfoViewController settingsItem]];
    [self.settingsItems addObject:[DBDocumentsViewController settingsItem]];
    
    if ([[[DBCompanyInfo sharedInstance] promocodesIsEnabled] boolValue]) {
        [self.settingsItems addObject:[[ViewControllerManager promocodeViewController] settingsItem]];
    }
    
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
        [self.settingsItems addObject:[[ViewControllerManager subscriptionViewController] settingsItem]];
    }
}

@end
