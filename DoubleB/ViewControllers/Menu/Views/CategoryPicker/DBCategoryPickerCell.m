//
//  DBCategoryPickerCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCategoryPickerCell.h"

@implementation DBCategoryPickerCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.categoryLabel.textColor = [UIColor db_defaultColor];
}

@end
