//
//  DBOrderViewHeader.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBOrderViewHeader.h"
#import "Order.h"
#import "UIGestureRecognizer+BlocksKit.h"

@interface DBOrderViewHeader ()
@property(strong, nonatomic) Order *order;
@end

@implementation DBOrderViewHeader

- (instancetype)initWithOrder:(Order *)order{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBOrderViewHeader" owner:self options:nil] firstObject];
    
    self.order = order;
    [self configure];
    
    return self;
}

- (void)configure{
    self.backgroundColor = [UIColor db_backgroundColor];
    
    NSString *temp = [NSString stringWithFormat:NSLocalizedString(@"Заказ #%@", nil), self.order.orderId];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:temp];
    [attributed setAttributes:@{NSForegroundColorAttributeName: [UIColor db_defaultColor],
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:16]}
                        range:NSMakeRange(0, attributed.string.length)];
    [attributed setAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor],
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16]}
                        range:NSMakeRange(0, attributed.string.length)];
    self.labelOrder.attributedText = attributed;
    
    /*[attributed addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:[attributed.string rangeOfString:[NSString stringWithFormat:@"#%@", self.order.orderId]]];*/
    
    self.labelOrder.userInteractionEnabled = YES;
    [self.labelOrder addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [GANHelper analyzeEvent:@"order_number_screen_click" label:self.order.orderId category:@"Order_info_screen"];
    }]];
    
    self.labelStatus.userInteractionEnabled = YES;
    [self.labelStatus addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [GANHelper analyzeEvent:@"order_status_click" label:self.order.orderId category:@"Order_info_screen"];
    }]];
}
@end
