//
//  PositionBalanceCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPositionBalanceCell.h"
#import "Venue.h"

@interface DBPositionBalanceCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@end

@implementation DBPositionBalanceCell

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionBalanceCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.balanceLabel.textColor = [UIColor db_defaultColor];
}

- (void)configure:(DBMenuPositionBalance *)balance {
    self.titleLabel.text = balance.venue.title;
    self.balanceLabel.text = [NSString stringWithFormat:@"x %ld", (long)balance.balance];
}

@end
