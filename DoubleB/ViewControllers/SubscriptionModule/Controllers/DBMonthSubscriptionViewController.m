//
//  DBFriendGiftViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 04.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBMonthSubscriptionViewController.h"
#import "DBMonthSubscriptionManager.h"
#import "DBPaymentCardsModuleView.h"
#import "MBProgressHUD.h"

#import "CAGradientLayer+Helper.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>

@import AddressBookUI;

@interface DBMonthSubscriptionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIView *cardsModuleContainer;

@property (weak, nonatomic) IBOutlet UIButton *orderButton;

@property (strong, nonatomic) DBPaymentCardsModuleView *cardsModuleView;

@property (strong, nonatomic) NSString *screenName;

@end

@implementation DBMonthSubscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Абонемент", nil);
    self.navigationController.navigationBar.topItem.title = @"";
    self.screenName = @"Month_subscription_screen";
    
    self.titleLabel.text = [DBMonthSubscriptionManager sharedInstance].subscriptionScreenTitle;
    self.descriptionLabel.text = [DBMonthSubscriptionManager sharedInstance].subscriptionScreenText;
    
    self.cardsModuleView = [[DBPaymentCardsModuleView alloc] initWithMode:DBPaymentCardsModuleViewModeManageCards];
    [self.cardsModuleContainer addSubview:self.cardsModuleView];
    self.cardsModuleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardsModuleView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.cardsModuleContainer];
    
    [self.orderButton setTitle:NSLocalizedString(@"Купить", nil) forState:UIControlStateNormal];
    [self.orderButton addTarget:self action:@selector(clickOrderButton) forControlEvents:UIControlEventTouchUpInside];
    self.orderButton.backgroundColor = [UIColor db_defaultColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self reloadGiftButton];
}

- (void)clickOrderButton{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [DBMonthSubscriptionManager sharedInstance] buySubscription:[DBMonthSubscriptionManager sharedInstance].selectedVariant callback:^(BOOL success, NSString *errorMessage) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        
//        if(success){
//            [self showAlert:@"Абонемент успешно оплачен"];
//        } else {
//            if(errorMessage){
//                [self showError:errorMessage];
//            } else {
//                [self showError:NSLocalizedString(@"NoInternetConnectionErrorMessage", nil)];
//            }
//        }
//    }];
}

- (void)reloadGiftButton{
    BOOL valid = YES;
    
    self.orderButton.enabled = valid;
    self.orderButton.alpha = valid ? 1.0 : 0.5;
}



@end