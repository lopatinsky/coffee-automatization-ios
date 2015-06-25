//
//  DBNewOrderTotalView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBNewOrderTotalView.h"
#import "OrderManager.h"
#import "DBPromoManager.h"
#import "Compatibility.h"

@implementation DBNewOrderTotalView

- (void)awakeFromNib{
    self.labelTotal.textColor = [UIColor db_defaultColor];
    
    [[OrderManager sharedManager] addObserver:self
                                   forKeyPath:@"totalPrice"
                                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                      context:nil];
    [[DBPromoManager sharedManager] addObserver:self
                                     forKeyPath:@"totalDiscount"
                                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                        context:nil];
    [[DBPromoManager sharedManager] addObserver:self
                                     forKeyPath:@"shippingPrice"
                                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                        context:nil];
    
    [self reloadTotal];
}

- (void)dealloc{
    [[OrderManager sharedManager] removeObserver:self forKeyPath:@"totalPrice"];
    [[DBPromoManager sharedManager] removeObserver:self forKeyPath:@"totalDiscount"];
    [[DBPromoManager sharedManager] removeObserver:self forKeyPath:@"shippingPrice"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if([keyPath isEqualToString:@"totalPrice"] || [keyPath isEqualToString:@"totalDiscount"] || [keyPath isEqualToString:@"shippingPrice"]){
        [self reloadTotal];
    }
}

- (void)reloadTotal{
    double actualTotal = [OrderManager sharedManager].totalPrice - [DBPromoManager sharedManager].totalDiscount + [DBPromoManager sharedManager].shippingPrice;
    NSString *actualTotalString = [NSString stringWithFormat:@"%.0f %@", actualTotal, [Compatibility currencySymbol]];
    
    NSString *oldTotalString;
    if([DBPromoManager sharedManager].totalDiscount > 0){
        oldTotalString= [NSString stringWithFormat:@"%.0f ", [OrderManager sharedManager].totalPrice];
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
}

- (void)startUpdating{
    self.totalRefreshControl.hidden = NO;
    [self.totalRefreshControl startAnimating];
}

- (void)endUpdating{
    [self.totalRefreshControl stopAnimating];
    self.totalRefreshControl.hidden = YES;
}

@end
