//
//  NewsHistoryTableViewCell.m
//  DoubleB
//
//  Created by Balaban Alexander on 27/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "NewsHistoryTableViewCell.h"

@implementation NewsHistoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    singleTap.numberOfTapsRequired = 1;
    [self.newsTextLabel addGestureRecognizer:singleTap];
}

- (void)tapped {
    [self.delegate tapOnCell:self.index];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
