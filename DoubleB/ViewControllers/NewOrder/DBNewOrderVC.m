//
//  DBNewOrderVC.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNewOrderVC.h"
#import "DBSettingsTableViewController.h"

#import "DBNOItemsModuleView.h"
#import "DBNOGiftItemsModuleView.h"
#import "DBNOBonusItemsModuleView.h"
#import "DBNOWalletModuleView.h"
#import "DBNOTotalModuleView.h"
#import "DBNOPromosModuleView.h"
#import "DBNOVenueModuleView.h"
#import "DBNOTimeModuleView.h"
#import "DBNOProfileModuleView.h"
#import "DBNOPaymentModuleView.h"
#import "DBNOCommentModuleView.h"
#import "DBNOndaModuleView.h"
#import "DBNOOrderModuleView.h"

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
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:self.analyticsCategory];
}

- (void)setupModules {
//    [self addModule:[DBNOItemsModuleView new]];
//    [self addModule:[DBNOBonusItemsModuleView new]];
//    [self addModule:[DBNOGiftItemsModuleView new]];
    [self addModule:[DBNOWalletModuleView new]];
    [self addModule:[DBNOTotalModuleView new]];
//    [self addModule:[DBNOPromosModuleView new]];
    [self addModule:[DBNOVenueModuleView new]];
    [self addModule:[DBNOTimeModuleView new]];
    [self addModule:[DBNOProfileModuleView new]];
    [self addModule:[DBNOPaymentModuleView new]];
    [self addModule:[DBNOCommentModuleView new]];
    [self addModule:[DBNOndaModuleView new]];
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

@end
