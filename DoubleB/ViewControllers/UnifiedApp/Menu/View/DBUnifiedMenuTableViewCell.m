//
//  DBUnifiedMenuTableViewCell.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedMenuTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation DBUnifiedMenuTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(NSDictionary *)info {
    self.nameLabel.text = info[@"name"];
    self.priceLabel.text = [NSString stringWithFormat:@"от %@%@", info[@"price"], [Compatibility currencySymbol]];
    self.infoLabel.text = [NSString stringWithFormat:@"в %@ заведениях",  info[@"info"]];
    [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:info[@"image"]]];
}

@end
