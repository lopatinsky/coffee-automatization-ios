//
//  DBUniversalModuleTextItemView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUniversalModuleTextItemView.h"
#import "DBUniversalModuleItem.h"
#import "DBPopupTextFieldView.h"

@interface DBUniversalModuleTextItemView ()<UITextFieldDelegate, DBPopupComponentDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) DBPopupTextFieldView *popupView;

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
//    _textField.keyboardType = _item.type == DBUniversalModuleItemTypeString ? UIKeyboardTypeDefault : UIKeyboardTypeNumberPad;
    self.textField.text = _item.text;
    
    self.popupView = [DBPopupTextFieldView create];
    self.popupView.placeholder = _item.placeholder;
    self.popupView.keyboardType = _item.type == DBUniversalModuleItemTypeString ? UIKeyboardTypeDefault : UIKeyboardTypeNumberPad;
    self.popupView.delegate = self;
    
//    [_textField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(db_moduleViewModalComponentContainer:)]) {
        self.popupView.text = _item.text;
        [self.popupView showFrom:self onView:[self.delegate db_moduleViewModalComponentContainer:self]];
    }
    
    return NO;
}

//- (void)textFieldDidChangeText:(UITextField *)textField{
//    _item.text = textField.text;
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [_item save];
//}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
//    return YES;
//}

- (void)db_componentWillDismiss:(DBPopupComponent *)component {
    _item.text = self.popupView.text;
    self.textField.text = _item.text;
    [_item save];
}

- (CGFloat)moduleViewContentHeight {
    if (_item.availableAccordingRestrictions) {
        return 40.f;
    } else {
        return 0.f;
    }
}


@end
