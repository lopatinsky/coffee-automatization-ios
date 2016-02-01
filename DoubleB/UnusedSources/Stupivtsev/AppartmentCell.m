//
//  AppartmentCell.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 14.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "AppartmentCell.h"

@interface AppartmentCell()
@property (weak, nonatomic) IBOutlet UIView *firstSeparator;
@property (weak, nonatomic) IBOutlet UIView *secondSeparator;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *housingTextField;
@property (weak, nonatomic) IBOutlet UITextField *AppartmentTextField;

@end

@implementation AppartmentCell

- (void)awakeFromNib {
    self.firstSeparator.backgroundColor = [UIColor db_defaultColor];
    self.secondSeparator.backgroundColor = [UIColor db_defaultColor];
    self.indicatorView.backgroundColor = [UIColor redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
