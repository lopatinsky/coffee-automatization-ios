//
//  DBPaymentCashModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPaymentCourierCardModuleView.h"
#import "OrderCoordinator.h"

@interface DBPaymentCourierCardModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tickImageView;

@end

@implementation DBPaymentCourierCardModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPaymentCourierCardModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.text = NSLocalizedString(@"Картой курьеру", nil);
    self.titleLabel.textColor = [UIColor blackColor];
    
    [self.iconImageView templateImageWithName:@"card"];
    
    [self.tickImageView templateImageWithName:@"tick"];
    
    @weakify(self)
    [self addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [OrderCoordinator sharedInstance].orderManager.paymentType = PaymentTypeCourierCard;
        [GANHelper analyzeEvent:@"payment_selected" label:@"courier_card" category:self.analyticsCategory];
        
        if([self.delegate respondsToSelector:@selector(db_paymentModuleDidSelectPaymentType:)]){
            [self.delegate db_paymentModuleDidSelectPaymentType:PaymentTypeCourierCard];
        }
    }]];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationNewPaymentType selector:@selector(reload)];
    
    [self reload:NO];

}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if ([OrderCoordinator sharedInstance].orderManager.paymentType == PaymentTypeCourierCard) {
        self.tickImageView.hidden = NO;
    } else {
        self.tickImageView.hidden = YES;
    }
}

- (void)touchAtLocation:(CGPoint)location {
    
}

@end
