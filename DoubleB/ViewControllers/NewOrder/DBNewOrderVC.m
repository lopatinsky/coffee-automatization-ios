//
//  DBNewOrderVC.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNewOrderVC.h"
#import "DBSettingsTableViewController.h"

#import "DBNOOrderItemsModuleView.h"
#import "DBNOGiftItemsModuleView.h"
#import "DBNOBonusItemsModuleView.h"
#import "DBNOItemAdditionModuleView.h"
#import "DBNOWalletModuleView.h"
#import "DBNOTotalModuleView.h"
#import "DBNOPromosModuleView.h"
#import "DBNODeliveryTypeModuleView.h"
#import "DBNOVenueModuleView.h"
#import "DBNOTimeModuleView.h"
#import "DBNOProfileModuleView.h"
#import "DBNOPaymentModuleView.h"
#import "DBNOCommentModuleView.h"
#import "DBNOndaModuleView.h"
#import "DBNOOrderModuleView.h"

#import "NetworkManager.h"

@interface DBNewOrderVC ()
@end

@implementation DBNewOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self db_setTitle:NSLocalizedString(@"Заказ", nil)];
    
    self.analyticsCategory = ORDER_SCREEN;
    
    [self setupSettingsNavigationItem];
    [self setupModules];
    
    [self layoutModules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Compatibility registerForNotifications];
    
    [self reloadModules:NO];
    
    [[NetworkManager sharedManager] addOperation:NetworkOperationCheckOrder];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:self.analyticsCategory];
}

- (void)setupModules {
    [self addModule:[DBNOOrderItemsModuleView new]];
    [self addModule:[DBNOBonusItemsModuleView new] topOffset:5];
    [self addModule:[DBNOGiftItemsModuleView new] topOffset:5];
    [self addModule:[DBNOItemAdditionModuleView new]];
    [self addModule:[DBNOWalletModuleView new]];
    [self addModule:[DBNOTotalModuleView new]];
    [self addModule:[DBNOPromosModuleView new]];
    [self addModule:[DBNODeliveryTypeModuleView new]];
    [self addModule:[DBNOVenueModuleView new] topOffset:5];
    [self addModule:[DBNOTimeModuleView new] topOffset:1];
    [self addModule:[DBNOProfileModuleView new] topOffset:1];
    [self addModule:[DBNOPaymentModuleView new]topOffset:5];
    [self addModule:[DBNOCommentModuleView new]topOffset:5];
    [self addModule:[DBNOndaModuleView new]topOffset:5];
    [self addModule:[DBNOOrderModuleView new]];
}

- (void)setupSettingsNavigationItem{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(clickSettings:)];
}

- (void)clickSettings:(id)sender {
    DBSettingsTableViewController *settingsController = [DBClassLoader loadSettingsViewController];
    settingsController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingsController animated:YES];
}

#pragma mark - DBModulesViewController

- (UIView *)containerForModuleModalComponent:(DBModuleView *)view {
    return self.tabBarController.view;
}

@end
