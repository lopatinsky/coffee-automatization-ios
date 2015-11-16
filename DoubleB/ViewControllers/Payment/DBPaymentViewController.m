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
#import "DBPaymentCardAdditionModuleView.h"
#import "DBPaymentCashModuleView.h"
#import "DBPaymentPayPalModuleView.h"

@interface DBPaymentViewController ()<DBPaymentModuleViewDelegate>
@end

@implementation DBPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    [self db_setTitle:NSLocalizedString(@"Оплата", nil)];
    if(self.mode == DBPaymentViewControllerModeSettings){
        self.analyticsCategory = CARDS_SCREEN;
    } else {
        self.analyticsCategory = PAYMENT_SCREEN;
    }
    
    // Cash module
    if([self moduleEnabled:[DBPaymentCashModuleView class]]){
        DBPaymentCashModuleView *cashModule = [DBPaymentCashModuleView new];
        cashModule.paymentDelegate = self;
        [self addModule:cashModule bottomOffset:5];
    }
    
    // PayPal module
    if([self moduleEnabled:[DBPaymentPayPalModuleView class]]){
        DBPaymentPayPalModuleView *paypalModule = [DBPaymentPayPalModuleView new];
        paypalModule.paymentDelegate = self;
        paypalModule.mode = self.mode == DBPaymentViewControllerModeChoosePayment ? DBPaymentPayPalModuleViewModePaymentType : DBPaymentPayPalModuleViewModeManageAccount;
        [self addModule:paypalModule bottomOffset:5];
    }
    
    // Cards module
    if([self moduleEnabled:[DBPaymentCardsModuleView class]]){
        DBPaymentCardsModuleViewMode mode = self.mode == DBPaymentViewControllerModeChoosePayment ? DBPaymentCardsModuleViewModeSelectPayment : DBPaymentCardsModuleViewModeManageCards;
        DBPaymentCardsModuleView *cardsModule = [[DBPaymentCardsModuleView alloc] initWithMode:mode];
        cardsModule.paymentDelegate = self;
        [self addModule:cardsModule bottomOffset:1];
        
        [self addModule:[DBPaymentCardAdditionModuleView new]];
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

- (BOOL)moduleEnabled:(Class)moduleClass {
    BOOL result = NO;
    
    if ([moduleClass isEqual:[DBPaymentCashModuleView class]]) {
        result = [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCash];
        result = result && self.mode == DBPaymentViewControllerModeChoosePayment;
        result = result && (self.paymentTypes ? [self.paymentTypes containsObject:@(PaymentTypeCash)] : YES);
    }
    
    if ([moduleClass isEqual:[DBPaymentCardsModuleView class]]) {
        result = [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypeCard];
        result = result && (self.paymentTypes ? [self.paymentTypes containsObject:@(PaymentTypeCard)] : YES);
    }
    
    if ([moduleClass isEqual:[DBPaymentPayPalModuleView class]]) {
        result = [[IHPaymentManager sharedInstance] paymentTypeAvailable:PaymentTypePayPal];
        result = result && (self.paymentTypes ? [self.paymentTypes containsObject:@(PaymentTypePayPal)] : YES);
    }
    
    return result;
}

#pragma mark - DBPaymentModuleViewDelegate

- (void)db_paymentModuleDidSelectPaymentType:(PaymentType)paymentType {
    if(self.mode == DBPaymentCardsModuleViewModeSelectPayment){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
