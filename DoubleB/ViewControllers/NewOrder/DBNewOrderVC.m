//
//  DBNewOrderVC.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNewOrderVC.h"

#import "DBNOOrderItemsModuleView.h"
#import "DBNOGiftItemsModuleView.h"
#import "DBNOBonusItemsModuleView.h"
#import "DBNOBonusItemAdditionModuleView.h"
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
    
    [self setupModules];
    
    DBNOOrderModuleView *orderModule = [DBNOOrderModuleView new];
    orderModule.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:orderModule];
    [orderModule alignLeading:@"0" trailing:@"0" toView:self.view];
    [orderModule alignBottomEdgeWithView:self.view predicate:@"0"];
    self.bottomInset = orderModule.frame.size.height;
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
    [self addModule:[DBNOGiftItemsModuleView new] topOffset:5];
    [self addModule:[DBNOBonusItemsModuleView new] topOffset:5];
    [self addModule:[DBNOBonusItemAdditionModuleView new]];
    [self addModule:[DBNOProfileModuleView new] topOffset:10];
    [self addModule:[DBNODeliveryTypeModuleView new] topOffset:5];
    [self addModule:[DBNOVenueModuleView new] topOffset:1];
    [self addModule:[DBNOTimeModuleView new] topOffset:1];
    [self addModule:[DBNOPaymentModuleView new]topOffset:5];
    [self addModule:[DBNOCommentModuleView new]topOffset:5];
    [self addModule:[DBNOndaModuleView new]topOffset:5];
    [self addModule:[DBNOWalletModuleView new] topOffset:1];
    [self addModule:[DBNOTotalModuleView new] topOffset:1];
    [self addModule:[DBNOPromosModuleView new] topOffset:1];
    
    [self layoutModules];
}

#pragma mark - DBModulesViewController

- (UIView *)containerForModuleModalComponent:(DBModuleView *)view {
    return self.navigationController.view;
}

@end
