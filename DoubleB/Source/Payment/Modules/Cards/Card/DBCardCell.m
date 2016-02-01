//
//  DBCardCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 10.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBCardCell.h"

@implementation DBCardCell

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBCardCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.separator.backgroundColor = [UIColor db_backgroundColor];
}

- (void)setChecked:(BOOL)checked{
    _checked = checked;
    
    if(checked){
        self.cardActiveIndicator.hidden = NO;
        [self.cardActiveIndicator templateImageWithName:@"tick"];
    } else {
        self.cardActiveIndicator.hidden = YES;
    }
}

@end
