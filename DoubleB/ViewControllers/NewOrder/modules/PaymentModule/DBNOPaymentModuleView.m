//
//  DBNOPaymentModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOPaymentModuleView.h"
#import "OrderCoordinator.h"
#import "DBCardsManager.h"
#import "DBPayPalManager.h"

#import "DBPaymentViewController.h"

@interface DBNOPaymentModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *paymentImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) OrderCoordinator *orderCoordinator;

@end

@implementation DBNOPaymentModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOPaymentModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.paymentImageView templateImageWithName:@"payment"];
     
    _orderCoordinator = [OrderCoordinator sharedInstance];
    [_orderCoordinator addObserver:self withKeyPath:CoordinatorNotificationNewPaymentType selector:@selector(reload)];
     
    [self reload:NO];
}

- (void)dealloc {
    [_orderCoordinator removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    switch (_orderCoordinator.orderManager.paymentType) {
        case PaymentTypeNotSet:
            [_orderCoordinator.orderManager selectIfPossibleDefaultPaymentType];
            if(_orderCoordinator.orderManager.paymentType != PaymentTypeNotSet){
                [self reload:animated];
            } else {
                self.titleLabel.textColor = [UIColor db_errorColor];
                self.titleLabel.text = NSLocalizedString(@"Выберите тип оплаты", nil);
            }
            break;
            
        case PaymentTypeCard:{
            DBPaymentCard *defaultCard = [DBCardsManager sharedInstance].defaultCard;
            if (defaultCard) {
                NSString *cardNumber = defaultCard.pan;
                NSString *pan = [cardNumber substringFromIndex:cardNumber.length-4];
                self.titleLabel.text = [NSString stringWithFormat:@"%@ - **** **** **** %@", defaultCard.cardIssuer, pan];
                self.titleLabel.textColor = [UIColor blackColor];
            } else {
                self.titleLabel.text = NSLocalizedString(@"Нет карт", nil);
                self.titleLabel.textColor = [UIColor db_errorColor];
            }
        }break;
            
        case PaymentTypeCash:
            self.titleLabel.textColor = [UIColor blackColor];
            self.titleLabel.text = NSLocalizedString(@"Наличные", nil);
            break;
            
        case PaymentTypePayPal:
            if([DBPayPalManager sharedInstance].loggedIn){
                self.titleLabel.textColor = [UIColor blackColor];
                self.titleLabel.text = @"PayPal";
            } else {
                _orderCoordinator.orderManager.paymentType = PaymentTypeNotSet;
                [self reload:animated];
            }
            break;
            
        default:
            break;
    }
}


- (void)touchAtLocation:(CGPoint)location {
    NSString *label = @"";
    switch (_orderCoordinator.orderManager.paymentType) {
        case PaymentTypeNotSet:
            label = @"not_set";
            break;
        case PaymentTypeCash:
            label = @"cash";
            break;
        case PaymentTypeCard:
            label = @"card";
            break;
        case PaymentTypePayPal:
            label = @"paypal";
            break;
        case PaymentTypeExtraType:
            label = @"extra_type";
            break;
    }
    
    [GANHelper analyzeEvent:@"payment_click" label:label category:self.analyticsCategory];
    
    DBPaymentViewController *paymentVC = [DBPaymentViewController new];
    paymentVC.mode = DBPaymentViewControllerModeChoosePayment;
    paymentVC.hidesBottomBarWhenPushed = YES;
    [self.ownerViewController.navigationController pushViewController:paymentVC animated:YES];
}

@end
