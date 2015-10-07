//
//  DBPaymentViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPaymentViewController.h"

#import "IHPaymentManager.h"
#import "OrderCoordinator.h"

#import "DBPaymentCardsModuleView.h"
#import "DBPaymentCashModuleView.h"
#import "DBPaymentPayPalModuleView.h"

@interface DBPaymentViewController ()<DBPaymentModuleViewDelegate>
@property (strong, nonatomic) NSString *analyticsCategory;

@property (strong, nonatomic) NSArray *availablePaymentTypes;
@end

@implementation DBPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    self.availablePaymentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsAvailablePaymentTypes];
    
    if(self.mode == DBPaymentViewControllerModeManage){
        self.title = NSLocalizedString(@"Карты", nil);
        self.analyticsCategory = CARDS_SCREEN;
        
        if([self.availablePaymentTypes containsObject:@(PaymentTypePayPal)]){
            self.title = NSLocalizedString(@"Электронные платежи", nil);
        }
    } else {
        self.title = NSLocalizedString(@"Оплата", nil);
        self.analyticsCategory = PAYMENT_SCREEN;
    }
    
    // Cash module
    if([self.availablePaymentTypes containsObject:@(PaymentTypeCash)] && self.mode == DBPaymentViewControllerModeChoosePayment){
        DBPaymentCashModuleView *cashModule = [DBPaymentCashModuleView new];
        cashModule.analyticsCategory = self.analyticsCategory;
        cashModule.ownerViewController = self;
        cashModule.delegate = self;
        [self.modules addObject:cashModule];
    }
    
    // PayPal module
    if([self.availablePaymentTypes containsObject:@(PaymentTypePayPal)]){
        DBPaymentPayPalModuleView *paypalModule = [DBPaymentPayPalModuleView new];
        paypalModule.analyticsCategory = self.analyticsCategory;
        paypalModule.ownerViewController = self;
        paypalModule.delegate = self;
        paypalModule.mode = self.mode == DBPaymentViewControllerModeChoosePayment ? DBPaymentPayPalModuleViewModePaymentType : DBPaymentPayPalModuleViewModeManageAccount;
        [self.modules addObject:paypalModule];
    }
    
    // Cards module
    if([self.availablePaymentTypes containsObject:@(PaymentTypeCard)]){
        DBPaymentCardsModuleViewMode mode = self.mode == DBPaymentViewControllerModeChoosePayment ? DBPaymentCardsModuleViewModeSelectPayment : DBPaymentCardsModuleViewModeManageCards;
        DBPaymentCardsModuleView *cardsModule = [[DBPaymentCardsModuleView alloc] initWithMode:mode];
        cardsModule.analyticsCategory = self.analyticsCategory;
        cardsModule.ownerViewController = self;
        cardsModule.delegate = self;
        [self.modules addObject:cardsModule];
    }
    
    [self layoutModules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:self.analyticsCategory];
    
    [self reloadModules:NO];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:self.analyticsCategory];
    }
}

#pragma mark - DBPaymentModuleViewDelegate

- (void)db_paymentModuleDidSelectPaymentType:(PaymentType)paymentType {
    if(self.mode == DBPaymentCardsModuleViewModeSelectPayment){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
