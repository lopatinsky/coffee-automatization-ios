//
//  OrderViewFooter.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBOrderViewFooter.h"
#import "Order.h"
#import "Venue.h"
#import "Compatibility.h"

@interface DBOrderViewFooter ()
@property(strong, nonatomic) Order *order;

@property (nonatomic) double initialHeight;
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
    [self configure];
    
    return self;
}

- (void)awakeFromNib {
    self.initialHeight = self.frame.size.height;
}

- (void)configure {
    NSMutableAttributedString *string;
    if ([self.order.realTotal isEqualToNumber:self.order.total]) {
        string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Итого: %ld %@", nil), (long)self.order.total.integerValue, [Compatibility currencySymbol]]];
    } else {
        string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Итого: %ld %ld %@", nil),
                                                                    (long)self.order.total.integerValue, (long)self.order.realTotal.integerValue, [Compatibility currencySymbol]]];
        [string setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0], NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)}
                        range:NSMakeRange(7, [[self.order.total stringValue] length])];
    }
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor db_defaultColor] range:NSMakeRange(0, 6)];
    self.labelTotal.attributedText = string;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.labelDate.text = [NSString stringWithFormat:NSLocalizedString(@"Готов к %@", nil), self.order.formattedTimeString];
    
    if([self.order.deliveryType intValue] == DeliveryTypeIdShipping){
        self.labelAddress.text = self.order.shippingAddress;
    } else {
        self.labelAddress.text = [self.order.venue address];
    }
    
    [self.venueImageView templateImageWithName:@"venue.png"];
}

- (void)layoutSubviews{
    CGRect rect = self.frame;
    rect.size.height = self.initialHeight;
    self.frame = rect;
    
    [super layoutSubviews];
}

@end
