//
//  discountMessageCell.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBDiscountMessageCell.h"

@implementation DBDiscountMessageCell

- (void)awakeFromNib {
    self.contentView.backgroundColor = [UIColor db_backgroundColor];
    self.messageLabel.textColor = [UIColor db_defaultColor];
}

@end
