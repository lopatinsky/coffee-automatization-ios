//
//  DBSubscriptionTableViewCell.m
//  DoubleB
//
//  Created by Balaban Alexander on 21/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBSubscriptionTableViewCell.h"

@implementation DBSubscriptionTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.desciptionLabel.numberOfLines = 0;
    self.desciptionLabel.adjustsFontSizeToFitWidth = YES;
    [self.tickImageView templateImageWithName:@"tick" tintColor:[UIColor db_defaultColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
