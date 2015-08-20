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

@interface DBPaymentViewController ()
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
        [self.modules addObject:cashModule];
    }
    
    // Cards module
    if([self.availablePaymentTypes containsObject:@(PaymentTypeCard)]){
        DBPaymentCardsModuleView *cardsModule = [DBPaymentCardsModuleView new];
        cardsModule.analyticsCategory = self.analyticsCategory;
        cardsModule.ownerViewController = self;
        cardsModule.mode = self.mode == DBPaymentViewControllerModeChoosePayment ? DBPaymentCardsModuleViewModeSelectCardPayment : DBPaymentCardsModuleViewModeManageCards;
        [self.modules addObject:cardsModule];
    }
    
    // PayPal module
    if([self.availablePaymentTypes containsObject:@(PaymentTypePayPal)]){
        DBPaymentPayPalModuleView *paypalModule = [DBPaymentPayPalModuleView new];
        paypalModule.analyticsCategory = self.analyticsCategory;
        paypalModule.ownerViewController = self;
        paypalModule.mode = self.mode == DBPaymentViewControllerModeChoosePayment ? DBPaymentPayPalModuleViewModePaymentType : DBPaymentPayPalModuleViewModeManageAccount;
        [self.modules addObject:paypalModule];
    }
    
    [self layoutModules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:self.analyticsCategory];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:self.analyticsCategory];
    }
}

@end
