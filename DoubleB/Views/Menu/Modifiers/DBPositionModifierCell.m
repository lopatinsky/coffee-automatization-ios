//
//  DBPositionModifierCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionModifierCell.h"

@interface DBPositionModifierCell ()
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation DBPositionModifierCell

- (void)awakeFromNib {
    [self.arrowImageView templateImageWithName:@"modifier_arrow_icon"];
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
}

@end
