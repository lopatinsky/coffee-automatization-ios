//
//  DBNewOrderViewHeader.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBNewOrderViewHeader.h"
#import "OrderManager.h"
#import "UIView+FLKAutoLayout.h"
#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>

@interface DBNewOrderViewHeader ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@end

@implementation DBNewOrderViewHeader

- (void)awakeFromNib{
    self.backgroundColor = [UIColor db_backgroundColor];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    if ([OrderManager sharedManager].orderId) {
        [self reloadOrderId:[OrderManager sharedManager].orderId];
    } else {
        self.titleLabel.attributedText = nil;
        self.titleLabel.text = @"";
        
        [[OrderManager sharedManager] registerNewOrderWithCompletionHandler:nil];
    }
    
    self.titleLabel.userInteractionEnabled = YES;
    [self.titleLabel addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [GANHelper analyzeEvent:@"order_number_click" category:@"Order_screen"];
    }]];
    
    [[OrderManager sharedManager] addObserver:self
                                   forKeyPath:@"orderId"
                                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                      context:nil];
}

- (void)dealloc{
//    [[OrderManager sharedManager] removeObserver:self forKeyPath:@"orderId"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if([keyPath isEqualToString:@"orderId"]){
        [self reloadOrderId:[OrderManager sharedManager].orderId];
    }
}

- (void)reloadOrderId:(NSString *)orderId{
    if(!orderId || [orderId isEqualToString:@""])
        return;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:
                                         [NSString stringWithFormat:NSLocalizedString(@"Номер заказа: %@", nil), orderId]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor db_blueColor] range:NSMakeRange(0, 13)];
    self.titleLabel.attributedText = string;
}

@end
