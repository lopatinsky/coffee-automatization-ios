//
//  DBUniversalModuleTextItemView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUniversalModuleTextItemView.h"
#import "DBUniversalModuleItem.h"

@interface DBUniversalModuleTextItemView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation DBUniversalModuleTextItemView

- (instancetype)initWithItem:(DBUniversalModuleItem *)item {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBUniversalModuleTextItemView" owner:self options:nil] firstObject];
    
    _item = item;
    
    [self commonInit];
    
    return self;
}

- (void)awakeFromNib {
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    self.textField.delegate = self;
}

- (void)commonInit {
    self.textField.placeholder = _item.placeholder;
    _textField.keyboardType = UIKeyboardTypeDefault;
    self.textField.text = _item.text;
    
    [_textField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChangeText:(UITextField *)textField{
    _item.text = textField.text;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [_item save];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
