//
//  OrderViewFooter.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBOrderViewFooter.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "Order.h"
#import "Venue.h"
#import "Compatibility.h"

@interface DBOrderViewFooter ()
@property(strong, nonatomic) Order *order;
@end

@implementation DBOrderViewFooter

- (instancetype)initWithFrame:(CGRect)rect order:(Order *)order{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBOrderViewFooter" owner:self options:nil] firstObject];
    
    self.frame = rect;
    
    self.order = order;
    [self configure];
    
    return self;
}

- (instancetype)initWithOrder:(Order *)order{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBOrderViewFooter" owner:self options:nil] firstObject];
    
    self.order = order;
//    CGRect rect = self.frame;
//    rect.size.height = 100;
//    self.frame = rect;
    [self configure];
    
    return self;
}

- (void)configure{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Итого: %ld %@", nil), (long)self.order.total.integerValue, [Compatibility currencySymbol]]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor db_defaultColor] range:NSMakeRange(0, 6)];
    self.labelTotal.attributedText = string;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.labelDate.text = [NSString stringWithFormat:NSLocalizedString(@"Готов к %@", nil), [formatter stringFromDate: self.order.createdAt]];
    self.labelAddress.text = [self.order.venue address];
    
    @weakify(self);
    self.labelTotal.userInteractionEnabled = YES;
    [self.labelTotal addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        [GANHelper analyzeEvent:@"order_price_click" label:self.order.orderId category:@"Order_info_screen"];
    }]];
    
    self.labelAddress.userInteractionEnabled = YES;
    [self.labelAddress addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        [GANHelper analyzeEvent:@"order_delivery_cafe_click" label:self.order.orderId category:@"Order_info_screen"];
    }]];
    
    self.labelDate.userInteractionEnabled = YES;
    [self.labelDate addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        [GANHelper analyzeEvent:@"order_delivery_time_click" label:self.order.orderId category:@"Order_info_screen"];
    }]];
}

@end
