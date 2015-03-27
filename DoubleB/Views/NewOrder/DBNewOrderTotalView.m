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
    self.labelTotal.textColor = [UIColor db_blueColor];
    
    [[OrderManager sharedManager] addObserver:self
                                   forKeyPath:@"totalPrice"
                                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                      context:nil];
    
    [self reloadTotal];
}

- (void)dealloc{
    [[OrderManager sharedManager] removeObserver:self forKeyPath:@"totalPrice"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if([keyPath isEqualToString:@"totalPrice"]){
        [self reloadTotal];
    }
}

- (void)reloadTotal{
    double actualTotal = [OrderManager sharedManager].totalPrice;
    NSString *actualTotalString = [NSString stringWithFormat:@"%ld %@", (long)actualTotal, [Compatibility currencySymbol]];
    
    NSString *oldTotalString;
    if([OrderManager sharedManager].initialTotalPrice != actualTotal){
        oldTotalString= [NSString stringWithFormat:@"%ld ", (long)[OrderManager sharedManager].initialTotalPrice];
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
