//
//  DBNewOrderTotalView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBNewOrderTotalView.h"
#import "OrderManager.h"
#import "Compatibility.h"

@implementation DBNewOrderTotalView

- (void)awakeFromNib{
    self.labelTotal.textColor = [UIColor db_defaultColor];
    
    [[OrderManager sharedManager] addObserver:self
                                   forKeyPath:@"totalPrice"
                                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                      context:nil];
    [[OrderManager sharedManager] addObserver:self
                                   forKeyPath:@"initialTotalPrice"
                                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                      context:nil];
    
    [self reloadTotal];
}

- (void)dealloc{
    [[OrderManager sharedManager] removeObserver:self forKeyPath:@"totalPrice"];
    [[OrderManager sharedManager] removeObserver:self forKeyPath:@"initialTotalPrice"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if([keyPath isEqualToString:@"totalPrice"] || [keyPath isEqualToString:@"initialTotalPrice"]){
        [self reloadTotal];
    }
}

- (void)reloadTotal{
    double actualTotal = [OrderManager sharedManager].totalPrice;
    NSString *actualTotalString = [NSString stringWithFormat:@"%.0f %@", actualTotal, [Compatibility currencySymbol]];
    
    NSString *oldTotalString;
    if([OrderManager sharedManager].initialTotalPrice != actualTotal){
        oldTotalString= [NSString stringWithFormat:@"%.0f ", [OrderManager sharedManager].initialTotalPrice];
    } else {
        oldTotalString = @"";
    }
    
    NSMutableAttributedString *totalString = [[NSMutableAttributedString alloc] initWithString:oldTotalString];
    
    [totalString addAttribute:NSStrikethroughStyleAttributeName
                        value:@(NSUnderlineStyleSingle)
                        range:NSMakeRange(0, oldTotalString.length)];
    
    self.labelTotal.text = NSLocalizedString(@"Итого: ", nil);
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
