//
//  DBPaymentCashModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPaymentCashModuleView.h"
#import "OrderCoordinator.h"

#import "UIGestureRecognizer+BlocksKit.h"

@interface DBPaymentCashModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tickImageView;

@end

@implementation DBPaymentCashModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPaymentCashModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.text = NSLocalizedString(@"Наличные", nil);
    self.titleLabel.textColor = [UIColor blackColor];
    
    [self.iconImageView templateImageWithName:@"cash"];
    
    [self.tickImageView templateImageWithName:@"tick"];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationNewPaymentType selector:@selector(reload)];
    
    [self reload:NO];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if ([OrderCoordinator sharedInstance].orderManager.paymentType == PaymentTypeCash){
        self.tickImageView.hidden = NO;
    } else {
        self.tickImageView.hidden = YES;
    }
}

- (void)touchAtLocation:(CGPoint)location {
    [OrderCoordinator sharedInstance].orderManager.paymentType = PaymentTypeCash;
    [GANHelper analyzeEvent:@"payment_selected" label:@"cash" category:self.analyticsCategory];
    
    if([self.paymentDelegate respondsToSelector:@selector(db_paymentModuleDidSelectPaymentType:)]){
        [self.paymentDelegate db_paymentModuleDidSelectPaymentType:PaymentTypeCash];
    }
}

@end
