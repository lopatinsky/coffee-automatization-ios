//
//  DBNOTotalModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOTotalModuleView.h"
#import "OrderCoordinator.h"

@interface DBNOTotalModuleView ()
@property (weak, nonatomic) IBOutlet UIView *sumView;
@property (weak, nonatomic) IBOutlet UILabel *sumLabel;
@property (weak, nonatomic) IBOutlet UILabel *sumTotal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSumViewHeight;
@property (nonatomic) NSInteger initialSumViewHeight;

@property (weak, nonatomic) IBOutlet UIView *shippingView;
@property (weak, nonatomic) IBOutlet UILabel *shippingLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingTotal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintShippingViewHeight;
@property (nonatomic) NSInteger initialShippingViewHeight;

@property (weak, nonatomic) IBOutlet UIView *discountView;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountTotal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDiscountViewHeight;
@property (nonatomic) NSInteger initialDiscountViewHeight;

@property (weak, nonatomic) IBOutlet UIView *totalView;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTotal;
@property (nonatomic) NSInteger initialTotalViewHeight;

@property (strong, nonatomic) OrderCoordinator *orderCoordinator;
@end

@implementation DBNOTotalModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOTotalModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor db_backgroundColor];
    
    self.initialSumViewHeight = self.constraintSumViewHeight.constant;
    self.initialShippingViewHeight = self.constraintShippingViewHeight.constant;
    self.initialDiscountViewHeight = self.constraintDiscountViewHeight.constant;
    self.initialTotalViewHeight = self.totalView.frame.size.height;
    
    self.sumLabel.text = NSLocalizedString(@"Сумма", nil);
    self.shippingLabel.text = NSLocalizedString(@"Стоимость доставки", nil);
    self.discountLabel.text = NSLocalizedString(@"Скидка", nil);
    self.totalLabel.text = NSLocalizedString(@"Итого к оплате", nil);
    
    self.orderCoordinator = [OrderCoordinator sharedInstance];
    [_orderCoordinator addObserver:self withKeyPaths:@[CoordinatorNotificationOrderTotalPrice, CoordinatorNotificationOrderDiscount, CoordinatorNotificationOrderWalletDiscount, CoordinatorNotificationOrderShippingPrice] selector:@selector(reload)];
}

- (void)dealloc{
    [_orderCoordinator removeObserver:self];
}

- (void)reload:(BOOL)animated{
    [super reload:animated];
    
    if (_orderCoordinator.itemsManager.totalPrice == 0) {
        self.constraintSumViewHeight.constant = 0;
        self.sumView.hidden = YES;
    } else {
        self.constraintSumViewHeight.constant = self.initialSumViewHeight;
        self.sumView.hidden = NO;
        
        self.sumTotal.text = [NSString stringWithFormat:@"%.0f %@", _orderCoordinator.itemsManager.totalPrice, [Compatibility currencySymbol]];
    }
    
    if (_orderCoordinator.promoManager.shippingPrice == 0) {
        self.constraintShippingViewHeight.constant = 0;
        self.shippingView.hidden = YES;
    } else {
        self.constraintShippingViewHeight.constant = self.initialShippingViewHeight;
        self.shippingView.hidden = NO;
        
        self.shippingTotal.text = [NSString stringWithFormat:@"%.0f %@", _orderCoordinator.promoManager.shippingPrice, [Compatibility currencySymbol]];
    }
    
    double discount = _orderCoordinator.promoManager.discount;
    discount += _orderCoordinator.promoManager.walletActiveForOrder ? _orderCoordinator.promoManager.walletDiscount : 0;
    if (discount == 0) {
        self.constraintDiscountViewHeight.constant = 0;
        self.discountView.hidden = YES;
    } else {
        self.constraintDiscountViewHeight.constant = self.initialDiscountViewHeight;
        self.discountView.hidden = NO;
        
        self.discountTotal.text = [NSString stringWithFormat:@"%.0f %@", discount, [Compatibility currencySymbol]];
    }
    
    double total = _orderCoordinator.itemsManager.totalPrice + _orderCoordinator.promoManager.shippingPrice - discount;
    self.totalTotal.text = [NSString stringWithFormat:@"%.0f %@", total, [Compatibility currencySymbol]];
}

- (CGFloat)moduleViewContentHeight {
    int height = self.constraintSumViewHeight.constant + self.constraintShippingViewHeight.constant + self.constraintDiscountViewHeight.constant + self.initialTotalViewHeight;
    
    return height;
}

@end
