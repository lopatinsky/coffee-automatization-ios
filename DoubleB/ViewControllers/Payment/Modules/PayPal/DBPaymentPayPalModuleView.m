//
//  DBPaymentCashModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPaymentPayPalModuleView.h"
#import "OrderCoordinator.h"
#import "DBPayPalManager.h"

#import "UIViewController+DBPayPalManagement.h"
#import "UIGestureRecognizer+BlocksKit.h"

@interface DBPaymentPayPalModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tickImageView;

@end

@implementation DBPaymentPayPalModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPaymentPayPalModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.iconImageView templateImageWithName:@"paypal_icon"];
    
    [self.tickImageView templateImageWithName:@"tick"];
    
    @weakify(self)
    [self addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        
        if([DBPayPalManager sharedInstance].loggedIn){
            if(_mode == DBPaymentPayPalModuleViewModePaymentType){
                [OrderCoordinator sharedInstance].orderManager.paymentType = PaymentTypePayPal;
                [GANHelper analyzeEvent:@"payment_selected" label:@"paypal" category:self.analyticsCategory];
            }
        } else {
            [self.ownerViewController bindPayPal:nil];
        }
    }]];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationNewPaymentType selector:@selector(reload)];
    [[DBPayPalManager sharedInstance] addObserver:self withKeyPath:DBPayPalManagerNotificationAccountChange selector:@selector(reload)];
    
    [self reload:NO];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
    [[DBPayPalManager sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];

    if([DBPayPalManager sharedInstance].loggedIn){
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.text = NSLocalizedString(@"Использовать PayPal", nil);
    } else {
        self.titleLabel.textColor = [UIColor db_defaultColor];
        self.titleLabel.text = NSLocalizedString(@"Войти в аккаунт PayPal", nil);
    }
    
    if([OrderCoordinator sharedInstance].orderManager.paymentType == PaymentTypePayPal){
        self.tickImageView.hidden = NO;
    } else {
        self.tickImageView.hidden = YES;
    }
}

@end
