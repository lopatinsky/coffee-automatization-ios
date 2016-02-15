//
//  DBPhoneConfirmationView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBPhoneConfirmationView.h"
#import "DBPlatiusManager.h"

#import "AKNumericFormatter.h"
#import "UITextField+AKNumericFormatter.h"


@interface DBPhoneConfirmationView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *textFieldBottomView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextFieldWidth;
@end

@implementation DBPhoneConfirmationView

+ (DBPhoneConfirmationView *)create {
    DBPhoneConfirmationView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBPhoneConfirmationView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    _textField.delegate = self;
    [_textField addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
    
    [_continueButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
    [_continueButton addTarget:self action:@selector(continueButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.mode = DBPhoneConfirmationViewModePhone;
}

- (void)setMode:(DBPhoneConfirmationViewMode)mode {
    _mode = mode;
    if (mode == DBPhoneConfirmationViewModePhone) {
        _textField.keyboardType = UIKeyboardTypePhonePad;
        _textField.secureTextEntry = NO;
        _textField.text = [DBPlatiusManager sharedInstance].confirmedPhone.value;
        
        NSString *mask = @"+* (***) ***-**-**";
        
        _textField.text = [AKNumericFormatter formatString:[DBPlatiusManager sharedInstance].confirmedPhone.value usingMask:mask placeholderCharacter:'*'];
        _textField.numericFormatter = [AKNumericFormatter formatterWithMask:mask placeholderCharacter:'*'];
        
        _constraintTextFieldWidth.constant = 150.f;
        
        _continueButton.hidden = NO;
        [_continueButton setTitle:NSLocalizedString(@"Получить код", nil) forState:UIControlStateNormal];
    } else {
        _textField.keyboardType = UIKeyboardTypeDecimalPad;
        _textField.secureTextEntry = YES;
        _textField.text = @"";
        _textField.numericFormatter = nil;
        
        _constraintTextFieldWidth.constant = 50.f;
        
        _continueButton.hidden = YES;
        [_continueButton setTitle:NSLocalizedString(@"Отправить", nil) forState:UIControlStateNormal];
    }
}

- (void)continueButtonClick {
    if (_mode == DBPhoneConfirmationViewModePhone) {
        [self requestSms];
    } else {
        [self sendCode];
    }
}

- (void)requestSms {
    _continueButton.hidden = YES;
    [_activityIndicator startAnimating];
    [[DBPlatiusManager sharedInstance] requestSms:^(BOOL success, NSString *description) {
        [_activityIndicator stopAnimating];
        
        if (success) {
            self.mode = DBPhoneConfirmationViewModeCode;
        } else {
            
        }
    }];
}

- (void)sendCode {
    [_activityIndicator startAnimating];
    [[DBPlatiusManager sharedInstance] sendConfirmationCode:_textField.text callback:^(BOOL success) {
        [_activityIndicator stopAnimating];
        
        if (success) {
            if ([_delegate respondsToSelector:@selector(db_phoneConfirmationViewConfirmedPhone:)]) {
                [_delegate db_phoneConfirmationViewConfirmedPhone:self];
            }
        } else {
            _continueButton.hidden = NO;
        }
    }];
}

- (void)savePhone {
    NSString *phoneText = self.textField.text;
    
    NSMutableCharacterSet *nonDigitsSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [nonDigitsSet invert];
    
    NSString *validText = [[phoneText componentsSeparatedByCharactersInSet:nonDigitsSet] componentsJoinedByString:@""];
    [[DBPlatiusManager sharedInstance] setPhone:validText];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (_mode == DBPhoneConfirmationViewModePhone) {
        if([[DBPlatiusManager  sharedInstance].confirmedPhone validCharacters:string] || [string isEqualToString:@""]){
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (_mode == DBPhoneConfirmationViewModePhone) {
        if([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"+"]) {
            textField.text = @"+7";
            [self savePhone];
        }
    }
}

- (void)textFieldEditingChanged {
    if (_mode == DBPhoneConfirmationViewModeCode) {
        if (_textField.text.length == 4) {
            [self sendCode];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - DBPopupViewControllerContent

- (CGFloat)db_popupContentContentHeight {
    return self.frame.size.height;
}


@end
