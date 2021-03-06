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
#import "DBNOOddModuleView.h"
#import "DBNOPersonsModuleView.h"
#import "DBNOndaModuleView.h"
#import "DBNOOrderModuleView.h"
#import "DBNOOrderApprovalModuleView.h"
#import "DBModuleSeparatorView.h"

#import "DBModulesManager.h"
#import "DBUniversalModulesManager.h"
#import "DBUniversalModule.h"

#import "OrderCoordinator.h"
#import "NetworkManager.h"
#import "DBClientInfo.h"
#import "DBPushManager.h"

@interface DBNewOrderVC ()
@property (strong, nonatomic) DBNOOrderModuleView *orderModule;
@end

@implementation DBNewOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self db_setTitle:NSLocalizedString(@"Заказ", nil)];
    
    self.analyticsCategory = ORDER_SCREEN;
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationNewVenue selector:@selector(reload)];
    
    [self setupModules];
    
    _orderModule = [DBNOOrderModuleView create];
    _orderModule.analyticsCategory = self.analyticsCategory;
    _orderModule.ownerViewController = self;
    _orderModule.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_orderModule];
    [_orderModule alignLeading:@"0" trailing:@"0" toView:self.view];
    [_orderModule alignBottomEdgeWithView:self.view predicate:@"0"];
    self.bottomInset = _orderModule.frame.size.height + 10;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GANHelper analyzeScreen:self.analyticsCategory];
    
    [OrderCoordinator sharedInstance].automaticUpdate = YES;
    
    [[DBPushManager sharedInstance] registerForNotifications];
    
    [self reloadModules:NO];
    [self.orderModule reload:NO];
    
    [[NetworkManager sharedManager] addOperation:NetworkOperationCheckOrder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [OrderCoordinator sharedInstance].automaticUpdate = NO;
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)setupModules {
    [self addModule:[DBNOOrderItemsModuleView create]];
    [self addModule:[DBNOGiftItemsModuleView create] topOffset:1];
    [self addModule:[DBNOBonusItemsModuleView create] topOffset:1];
    [self addModule:[DBNOBonusItemAdditionModuleView create]];
    
    [self addModule:[[DBModuleSeparatorView alloc] initWithHeight:10]];
    
    if (![DBClientInfo sharedInstance].clientPhone.valid || ![DBClientInfo sharedInstance].clientName.valid){
        [self addModule:[DBNOProfileModuleView create] topOffset:0 bottomOffset:5];
    }
    
    if ([DBCompanyInfo sharedInstance].deliveryTypes.count > 1 && ![[ApplicationConfig db_excludedOrderModules] containsObject:@(DBNOModulesDeliveryType)]) {
        [self addModule:[DBNODeliveryTypeModuleView create] topOffset:0];
    }
    
    [self addModule:[DBNOVenueModuleView create] topOffset:1];
    
    if (![[ApplicationConfig db_excludedOrderModules] containsObject:@(DBNOModulesTime)]) {
        [self addModule:[DBNOTimeModuleView create] topOffset:1];
    }
    
    [self addModule:[DBNOPaymentModuleView create]topOffset:5];
    
    if (![[ApplicationConfig db_excludedOrderModules] containsObject:@(DBNOModulesComment)]) {
        [self addModule:[DBNOCommentModuleView create]topOffset:5];
    }
    
    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypeOddSum]) {
        [self addModule:[DBNOOddModuleView create]topOffset:1];
    }
    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypePersonsCount]) {
        [self addModule:[DBNOPersonsModuleView create]topOffset:1];
    }
    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypeOrderApproval]) {
        [self addModule:[DBNOOrderApprovalModuleView create] topOffset:1];
    }

    // Universal modules
    for (DBUniversalModule *module in [DBUniversalOrderModulesManager sharedInstance].modules) {
        [self addModule:[module getModuleView] topOffset:0];
    }

    [self addModule:[DBNOndaModuleView create]topOffset:5];
    
    [self addModule:[[DBModuleSeparatorView alloc] initWithHeight:5]];
    
    [self addModule:[DBNOWalletModuleView create] topOffset:0 bottomOffset:1];
    [self addModule:[DBNOTotalModuleView create] topOffset:0];
    
    [self layoutModules];
}

- (void)reload {
    [self reloadModules:NO];
}


#pragma mark - DBModulesViewController

- (UIView *)containerForModuleModalComponent:(DBModuleView *)view {
    return self.navigationController.view;
}

@end