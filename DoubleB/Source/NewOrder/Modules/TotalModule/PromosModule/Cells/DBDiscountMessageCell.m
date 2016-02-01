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
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.messageLabel.textColor = [UIColor db_textGrayColor];
}

+ (CGFloat)labelHeight:(NSString *)text {
    CGSize titleSize = [text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 16, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.f]}
                                          context:nil].size;
    
    return titleSize.height;
}

@end
