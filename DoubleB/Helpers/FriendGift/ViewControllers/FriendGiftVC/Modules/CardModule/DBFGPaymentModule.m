//
//  DBFriendGiftPaymentModule.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBFGPaymentModule.h"
#import "DBCardsManager.h"
#import "DBPaymentViewController.h"
#import "IHPaymentManager.h"

#import "DBModuleHeaderView.h"

@interface DBFGPaymentModule ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBFGPaymentModule

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBFGPaymentModule" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    DBModuleHeaderView *header = [DBModuleHeaderView new];
    header.title = NSLocalizedString(@"Выберите карту для оплаты", nil);
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:header];
    [header alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.headerView];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    DBPaymentCard *defaultCard = [DBCardsManager sharedInstance].defaultCard;
    if (defaultCard) {
        NSString *cardNumber = defaultCard.pan;
        NSString *pan = [cardNumber substringFromIndex:cardNumber.length-4];
        self.titleLabel.text = [NSString stringWithFormat:@"%@ - **** **** **** %@", defaultCard.cardIssuer, pan];
        self.titleLabel.textColor = [UIColor blackColor];
    } else {
        self.titleLabel.text = NSLocalizedString(@"Нет карт", nil);
        self.titleLabel.textColor = [UIColor orangeColor];
    }
}

- (void)touchAtLocation:(CGPoint)location {
    [GANHelper analyzeEvent:@"gift_card_choice_click" category:self.analyticsCategory];
    
    DBPaymentViewController *paymentVC = [DBPaymentViewController new];
    paymentVC.mode = DBPaymentViewControllerModeChoosePayment;
    paymentVC.paymentTypes = @[@(PaymentTypeCard)];
    
    [self.ownerViewController.navigationController pushViewController:paymentVC animated:YES];
}

@end
