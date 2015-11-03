//
//  DBNOOrderModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOOrderModuleView.h"
#import "UIView+RoundedCorners.h"
#import "OrderCoordinator.h"
#import "NetworkManager.h"

@interface DBNOOrderModuleView ()
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) BOOL inProgress;

@end

@implementation DBNOOrderModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOOrderModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
    
    self.errorLabel.textColor = [UIColor db_errorColor];
    
    self.orderButton.backgroundColor = [UIColor db_grayColor];
    [self.orderButton setRoundedCorners];
    [self.orderButton setTitle:NSLocalizedString(@"Заказать", nil) forState:UIControlStateNormal];
    [self.orderButton addTarget:self action:@selector(clickOrderButton) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *events = @[CoordinatorNotificationOrderTotalPrice, CoordinatorNotificationOrderDiscount, CoordinatorNotificationOrderWalletDiscount, CoordinatorNotificationOrderShippingPrice, CoordinatorNotificationNewDeliveryType, CoordinatorNotificationNewSelectedTime, CoordinatorNotificationNewPaymentType, CoordinatorNotificationNewVenue, CoordinatorNotificationNewShippingAddress, CoordinatorNotificationNDAAccept];
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPaths:events selector:@selector(reload)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endAnimating) name:kDBConcurrentOperationCheckOrderSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endAnimating) name:kDBConcurrentOperationCheckOrderFailure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimating) name:kDBConcurrentOperationCheckOrderStarted object:nil];
}

- (void)viewWillAppearOnVC {
    [self reload:NO];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    self.errorLabel.hidden = YES;
    self.totalLabel.hidden = YES;
    self.orderButton.hidden = YES;
    
    if (_inProgress) {
        self.totalLabel.hidden = NO;
        self.orderButton.hidden = NO;
    } else {
        if (![OrderCoordinator sharedInstance].validOrder) {
            if ([OrderCoordinator sharedInstance].promoManager.errors.count > 0) {
                self.errorLabel.hidden = NO;
                [self reloadErrorLabel];
            } else {
                self.totalLabel.hidden = NO;
                self.orderButton.hidden = NO;
                [self reloadTotal];
                [self reloadOrderButton];
            }
        } else {
            self.totalLabel.hidden = NO;
            self.orderButton.hidden = NO;
            [self reloadTotal];
            [self reloadOrderButton];
        }
    }
}

- (void)reloadTotal {
    double discount = [OrderCoordinator sharedInstance].promoManager.discount;
    discount += [OrderCoordinator sharedInstance].promoManager.walletActiveForOrder ? [OrderCoordinator sharedInstance].promoManager.walletDiscount : 0;
    double total = [OrderCoordinator sharedInstance].itemsManager.totalPrice + [OrderCoordinator sharedInstance].promoManager.shippingPrice - discount;
    self.totalLabel.text = [NSString stringWithFormat:@"%.0f %@", total, [Compatibility currencySymbol]];
}

- (void)reloadOrderButton {
    if (![OrderCoordinator sharedInstance].validOrder) {
        self.orderButton.backgroundColor = [UIColor db_grayColor];
        self.orderButton.alpha = 0.5f;
    } else {
        self.orderButton.backgroundColor = [UIColor db_defaultColor];
        self.orderButton.alpha = 1;
    }
}

- (void)reloadErrorLabel {
    self.errorLabel.text = [[OrderCoordinator sharedInstance].promoManager.errors firstObject];
}

- (void)startAnimating{
    [self.activityIndicator startAnimating];
    _inProgress = YES;
    
    [self reload:YES];
}

- (void)endAnimating{
    [self.activityIndicator stopAnimating];
    _inProgress = NO;
    
    [self reload:YES];
}

- (void)clickOrderButton {
    [GANHelper analyzeEvent:@"order_button_click" category:ORDER_SCREEN];
}

@end
