//
//  PersonalAccountViewController.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 06.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "PersonalAccountViewController.h"
#import "UIImageView+Extension.h"
#import "DBMastercardPromo.h"
#import "OrderManager.h"
#import "Compatibility.h"

@interface PersonalAccountViewController ()
@property (weak, nonatomic) IBOutlet UILabel *walletTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@end

@implementation PersonalAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Личный счет", nil);
    
    self.walletTitleLabel.text = @"Ваш личный счет";
    self.walletDescriptionLabel.text = @"Это ваш личный счет, который пополняется на 5% от суммы заказа каждый раз, когда вы оплачиваете заказ картой. Накопленные баллы вы можете использовать для оплаты новых заказов.";
    
    self.walletTitleLabel.text = [DBMastercardPromo sharedInstance].walletBalanceTitleText;
    self.walletDescriptionLabel.text = [DBMastercardPromo sharedInstance].walletBalanceScreenText;
    
    self.balanceTitleLabel.text = NSLocalizedString(@"Ваш баланс:", nil);
    self.balanceTitleLabel.textColor = [UIColor db_blueColor];
}

- (void)viewWillAppear:(BOOL)animated {
    self.balanceLabel.text = [NSString stringWithFormat:@"%ld %@", (long)[DBMastercardPromo sharedInstance].walletBalance, [Compatibility currencySymbol]];
}

@end
