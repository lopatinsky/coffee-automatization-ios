//
//  DBBonusPositionDescriptionCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBBonusPositionDescriptionCell.h"

@interface DBBonusPositionDescriptionCell ()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation DBBonusPositionDescriptionCell

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBBonusPositionDescriptionCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.balanceTitleLabel.text = @"Баланс:";
    
    self.balanceLabel.textColor = [UIColor db_defaultColor];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
}

- (void)setBalance:(double)balance{
    _balance = balance;
    
    self.balanceLabel.text = [NSString stringWithFormat:@"%.f", balance];
}

@end
