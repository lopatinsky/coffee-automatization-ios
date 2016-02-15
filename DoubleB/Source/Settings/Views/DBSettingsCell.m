//
//  DBSettingsCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBSettingsCell.h"

@interface DBSettingsCell ()
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageViewWidth;
@property (nonatomic) NSInteger initialImageViewWidth;

@end

@implementation DBSettingsCell

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBSettingsCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.initialImageViewWidth = self.constraintImageViewWidth.constant;
    
    self.switchView.onTintColor = [UIColor db_defaultColor];
    [self.switchView addTarget:self action:@selector(switchViewDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.disclosureIndicator templateImageWithName:@"right_arrow_icon"];
}

- (void)setHasIcon:(BOOL)hasIcon{
    _hasIcon = hasIcon;
    
    self.constraintImageViewWidth.constant = hasIcon ? self.initialImageViewWidth : 0;
    [self.contentView layoutIfNeeded];
}

- (void)setHasSwitch:(BOOL)hasSwitch{
    _hasSwitch = hasSwitch;
    
    self.switchView.hidden = !hasSwitch;
    self.disclosureIndicator.hidden = hasSwitch;
}

- (void)switchViewDidChangeValue:(UISwitch *)sender{
    if([self.delegate respondsToSelector:@selector(db_settingsCell:didChangeSwitchValue:)]){
        [self.delegate db_settingsCell:self didChangeSwitchValue:self.switchView.isOn];
    }
}

@end
