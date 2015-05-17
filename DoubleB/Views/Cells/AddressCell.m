//
//  AddressCell.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 14.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "AddressCell.h"

@interface AddressCell() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;

@end

@implementation AddressCell

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    
    if (self) {
        self.cityTextField.text = text;
    }
    
    return self;
}

- (void)awakeFromNib {
    self.indicatorView.backgroundColor = [UIColor redColor];
    self.cityTextField.delegate = self;
    if ([self.cityTextField.text isEqualToString:@""]) {
        self.indicatorView.hidden = NO;
    } else {
        self.indicatorView.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTextFieldBoldWithSize:(CGFloat)size {
    self.cityTextField.font = [UIFont boldSystemFontOfSize:size];
    self.cityTextField.userInteractionEnabled = NO;
}

- (void)setTextFieldAlignmentCenter {
    self.cityTextField.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        self.indicatorView.hidden = NO;
    } else {
        self.indicatorView.hidden = YES;
    }
    
    [textField resignFirstResponder];
    return YES;
}

@end
