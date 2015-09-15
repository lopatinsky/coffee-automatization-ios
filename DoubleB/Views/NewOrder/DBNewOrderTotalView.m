//
//  DBNewOrderTotalView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBNewOrderTotalView.h"
#import "OrderCoordinator.h"

@interface DBNewOrderTotalView ()
@property (strong, nonatomic) OrderCoordinator *orderCoordinator;
@end

@implementation DBNewOrderTotalView

- (void)awakeFromNib{
    self.labelTotal.textColor = [UIColor db_defaultColor];
    
    self.totalRefreshControl.hidesWhenStopped = YES;
    
    self.labelShippingTotal.textColor = [UIColor db_defaultColor];
    
    self.orderCoordinator = [OrderCoordinator sharedInstance];
    [_orderCoordinator addObserver:self withKeyPaths:@[CoordinatorNotificationOrderTotalPrice, CoordinatorNotificationOrderDiscount, CoordinatorNotificationOrderWalletDiscount, CoordinatorNotificationOrderShippingPrice] selector:@selector(reloadTotal)];
    
    [self reloadTotal];
}

- (void)dealloc{
    [_orderCoordinator removeObserver:self];
}

- (void)reloadTotal{
    double actualTotal = _orderCoordinator.itemsManager.totalPrice - _orderCoordinator.promoManager.totalDiscount + _orderCoordinator.promoManager.shippingPrice;
    NSString *actualTotalString = [NSString stringWithFormat:@"%.0f %@", actualTotal, [Compatibility currencySymbol]];
    
    NSString *oldTotalString;
    if(_orderCoordinator.promoManager.totalDiscount > 0){
        oldTotalString= [NSString stringWithFormat:@"%.0f ", _orderCoordinator.itemsManager.totalPrice];
    } else {
        oldTotalString = @"";
    }
    
    NSMutableAttributedString *totalString = [[NSMutableAttributedString alloc] initWithString:oldTotalString];
    
    [totalString addAttribute:NSStrikethroughStyleAttributeName
                        value:@(NSUnderlineStyleSingle)
                        range:NSMakeRange(0, oldTotalString.length)];
    
    self.labelTotal.text = [NSString stringWithFormat:@"%@: ", NSLocalizedString(@"Итого", nil)];
    self.labelOldTotal.attributedText = totalString;
    self.labelActualTotal.text = actualTotalString;
    
    double shippingTotal = _orderCoordinator.promoManager.shippingPrice;
    if(shippingTotal > 0){
        self.labelShippingTotal.hidden = NO;
        self.labelShippingTotal.text = [NSString stringWithFormat:@"(%@: %.0f%@)", NSLocalizedString(@"Стоимость доставки", nil), shippingTotal, [Compatibility currencySymbol]];
    } else {
        self.labelShippingTotal.hidden = YES;
    }
}

- (void)startUpdating{
    [self.totalRefreshControl startAnimating];
}

- (void)endUpdating{
    [self.totalRefreshControl stopAnimating];
}

@end
