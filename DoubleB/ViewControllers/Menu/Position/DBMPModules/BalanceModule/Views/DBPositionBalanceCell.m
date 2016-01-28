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

@property (weak, nonatomic) IBOutlet UIImageView *tickImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTickImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTickImageTrailingSpace;
@property (nonatomic) double initialTickImageViewWidth;
@property (nonatomic) double initialTickImageTrailingSpace;

@end

@implementation DBPositionBalanceCell

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionBalanceCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.balanceLabel.textColor = [UIColor db_defaultColor];
    [self.tickImageView templateImageWithName:@"tick.png"];
    self.tickImageView.hidden = YES;
    
    self.initialTickImageViewWidth = self.constraintTickImageViewWidth.constant;
    self.initialTickImageTrailingSpace = self.constraintTickImageTrailingSpace.constant;
}

- (void)configure:(DBMenuPositionBalance *)balance {
    self.titleLabel.text = balance.venue.title;
    
    NSString *balanceString = [NSString stringWithFormat:@"x %ld", (long)balance.balance];
    if (balance.balance == -1) {
        balanceString = NSLocalizedString(@"Неизвестно", nil);
    }
    self.balanceLabel.text = balanceString;
}

- (void)setTickAvailable:(BOOL)tickAvailable {
    _tickAvailable = tickAvailable;
    
    self.constraintTickImageViewWidth.constant = _tickAvailable ? self.initialTickImageViewWidth : 0;
    self.constraintTickImageTrailingSpace.constant = _tickAvailable ? self.initialTickImageTrailingSpace: 0;
}

- (void)setTickSelected:(BOOL)tickSelected {
    _tickSelected = tickSelected;
    
    self.tickImageView.hidden = !_tickSelected;
}

@end
