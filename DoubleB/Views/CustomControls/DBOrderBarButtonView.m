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
    
    [self.orderImageView templateImageWithName:@"shopping_cart_icon.png" tintColor:[UIColor whiteColor]];
    
    self.countLabel.layer.cornerRadius = self.countLabel.frame.size.height / 2;
//    self.countLabel.layer.borderWidth = 1.f;
//    self.countLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.countLabel.layer.masksToBounds = YES;
    
    self.countLabel.textColor = [UIColor whiteColor];
    
//    self.countLabel.backgroundColor = [UIColor db_defaultColor];
}

@end
