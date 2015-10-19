//
//  DBNOTotalModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOTotalModuleView.h"
#import "OrderCoordinator.h"
#import "NetworkManager.h"

@interface DBNOTotalModuleView ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *totalRefreshControl;
@property (weak, nonatomic) IBOutlet UILabel *labelTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelActualTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelOldTotal;

@property (weak, nonatomic) IBOutlet UILabel *labelShippingTotal;

@property (strong, nonatomic) OrderCoordinator *orderCoordinator;
@end

@implementation DBNOTotalModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOTotalModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.labelTotal.textColor = [UIColor db_defaultColor];
    
    self.totalRefreshControl.hidesWhenStopped = YES;
    
    self.labelShippingTotal.textColor = [UIColor db_defaultColor];
    
    self.orderCoordinator = [OrderCoordinator sharedInstance];
    [_orderCoordinator addObserver:self withKeyPaths:@[CoordinatorNotificationOrderTotalPrice, CoordinatorNotificationOrderDiscount, CoordinatorNotificationOrderWalletDiscount, CoordinatorNotificationOrderShippingPrice] selector:@selector(reload)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimating) name:kDBConcurrentOperationCheckOrderSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimating) name:kDBConcurrentOperationCheckOrderFailure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimating) name:kDBConcurrentOperationCheckOrderStarted object:nil];
}

- (void)dealloc{
    [_orderCoordinator removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload:(BOOL)animated{
    [super reload:animated];
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

- (void)startAnimating{
    [self.totalRefreshControl startAnimating];
}

- (void)endAnimating{
    [self.totalRefreshControl stopAnimating];
}

@end
