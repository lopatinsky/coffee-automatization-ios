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
#import "DBNOVenueModelView.h"
#import "DBNOTimeModuleView.h"
#import "DBNOProfileModuleView.h"
#import "DBNOPaymentModuleView.h"
#import "DBNOCommentModuleView.h"
#import "DBNOndaModuleView.h"
#import "DBNOOrderModuleView.h"

@interface DBNewOrderVC ()
@property (strong, nonatomic) NSString *analyticsCategory;
@end

@implementation DBNewOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    [self db_setTitle:NSLocalizedString(@"Заказ", nil)];
    
    self.analyticsCategory = ORDER_SCREEN;
    
    [self setupSettingsNavigationItem];
    [self setupModules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Compatibility registerForNotifications];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:self.analyticsCategory];
}

- (void)setupModules {
    DBNOItemsModuleView *itemsModule = [DBNOItemsModuleView new];
    itemsModule.analyticsCategory = self.analyticsCategory;
    itemsModule.ownerViewController = self;
    [self.modules addObject:itemsModule];
    
    DBNOBonusItemsModuleView *bonusItemsModule = [DBNOBonusItemsModuleView new];
    bonusItemsModule.analyticsCategory = self.analyticsCategory;
    bonusItemsModule.ownerViewController = self;
    [self.modules addObject:bonusItemsModule];
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
