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
#import "DBPickerView.h"

#import "NSDate+Extension.h"

@interface DBUniversalModuleTextItemView ()<UITextFieldDelegate, DBPopupComponentDelegate, DBPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) DBPopupTextFieldView *popupView;

@property (strong, nonatomic) DBPickerView *pickerView;

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
    
    if (_item.type == DBUniversalModuleItemTypeString || _item.type == DBUniversalModuleItemTypeInteger) {
        self.popupView = [DBPopupTextFieldView create];
        self.popupView.placeholder = _item.placeholder;
        self.popupView.keyboardType = _item.type == DBUniversalModuleItemTypeString ? UIKeyboardTypeDefault : UIKeyboardTypeNumberPad;
        self.popupView.delegate = self;
        
        self.textField.text = _item.text;
    }
    
    if (_item.type == DBUniversalModuleItemTypeDate) {
        self.pickerView = [DBPickerView create:DBPickerViewModeDate];
        self.pickerView.pickerDelegate = self;
        self.pickerView.title = _item.placeholder;
        
        if (_item.minDate)
            self.pickerView.minDate = _item.minDate;
        if (_item.maxDate)
            self.pickerView.maxDate = _item.maxDate;
        
        if (_item.selectedDate)
            self.textField.text = [NSDate stringFromDate:_item.selectedDate format:@"dd.MM.yyyy"];
    }
    
    if (_item.type == DBUniversalModuleItemTypeItems) {
        self.pickerView = [DBPickerView create:DBPickerViewModeItems];
        self.pickerView.pickerDelegate = self;
        self.pickerView.title = _item.placeholder;
        
        [self.pickerView configureWithItems:_item.items];
        
        if (_item.selectedItem)
            self.textField.text = _item.selectedItem;
    }
    
//    [_textField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(db_moduleViewModalComponentContainer:)]) {
        if (_item.type == DBUniversalModuleItemTypeString || _item.type == DBUniversalModuleItemTypeInteger) {
            self.popupView.text = _item.text;
            [self.popupView showFrom:self onView:[self.delegate db_moduleViewModalComponentContainer:self]];
        }
        
        if (_item.type == DBUniversalModuleItemTypeDate) {
            if ([self.delegate respondsToSelector:@selector(db_moduleViewStartEditing:)]) {
                [self.delegate db_moduleViewStartEditing:self];
            }
            self.pickerView.selectedDate = _item.selectedDate;
            [self.pickerView showOnView:[self.delegate db_moduleViewModalComponentContainer:self] appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
        }
        
        if (_item.type == DBUniversalModuleItemTypeItems) {
            if ([self.delegate respondsToSelector:@selector(db_moduleViewStartEditing:)]) {
                [self.delegate db_moduleViewStartEditing:self];
            }
            self.pickerView.selectedIndex = _item.selectedItem ? [_item.items indexOfObject: _item.selectedItem] : 0;
            [self.pickerView showOnView:[self.delegate db_moduleViewModalComponentContainer:self] appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
        }
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
    if (_item.type == DBUniversalModuleItemTypeString || _item.type == DBUniversalModuleItemTypeInteger) {
        _item.text = self.popupView.text;
        self.textField.text = _item.text;
    }
    
    if (_item.type == DBUniversalModuleItemTypeDate) {
        _item.selectedDate = self.pickerView.selectedDate;
        
        if (_item.selectedDate)
            self.textField.text = [NSDate stringFromDate:_item.selectedDate format:@"dd.MM.yyyy"];
    }
    
    if (_item.type == DBUniversalModuleItemTypeItems) {
        _item.selectedItem = _item.items[self.pickerView.selectedIndex];
        
        if (_item.selectedItem)
            self.textField.text = _item.selectedItem;
    }
    
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
