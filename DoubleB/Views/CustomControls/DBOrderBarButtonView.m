//
//  DBOrderBarButtonView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBOrderBarButtonView.h"

@implementation DBOrderBarButtonView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBOrderBarButtonView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor clearColor];
    
    [self.orderImageView templateImageWithName:@"orders_icon.png" tintColor:[UIColor whiteColor]];
    
    self.totalLabel.textColor = [UIColor whiteColor];
}

@end
