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
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *textFieldBottomView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextFieldWidth;

@property (strong, nonatomic) NSString *errorMessage;
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
    
    _errorLabel.textColor = [UIColor db_errorColor];
}

- (void)setMode:(DBPhoneConfirmationViewMode)mode {
    _mode = mode;
    if (mode == DBPhoneConfirmationViewModePhone) {
        // Text
        _descriptionLabel.text = NSLocalizedString(@"Введите номер телефона, нажмите продолжить и дождитесь смс с Вашим кодом", nil);
        
        // TextField
        _textField.keyboardType = UIKeyboardTypePhonePad;
        _textField.secureTextEntry = NO;
        _textField.text = [DBPlatiusManager sharedInstance].confirmedPhone.value;
        
        NSString *mask = @"+* (***) ***-**-**";
        
        _textField.text = [AKNumericFormatter formatString:[DBPlatiusManager sharedInstance].confirmedPhone.value usingMask:mask placeholderCharacter:'*'];
        _textField.numericFormatter = [AKNumericFormatter formatterWithMask:mask placeholderCharacter:'*'];
        
        _constraintTextFieldWidth.constant = 150.f;
        
        // Continue Button
        _continueButton.hidden = NO;
        [_continueButton setTitle:NSLocalizedString(@"Продолжить", nil) forState:UIControlStateNormal];
    } else {
        // Text
        _descriptionLabel.text = NSLocalizedString(@"Введите полученный код", nil);
        
        // TextField
        _textField.keyboardType = UIKeyboardTypeDecimalPad;
        _textField.secureTextEntry = YES;
        _textField.text = @"";
        _textField.numericFormatter = nil;
        
        _constraintTextFieldWidth.constant = 50.f;
        
        // Continue Button
        _continueButton.hidden = YES;
        [_continueButton setTitle:NSLocalizedString(@"Отправить", nil) forState:UIControlStateNormal];
    }
    
    _errorLabel.text = self.errorMessage;
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
            self.errorMessage = nil;
            self.mode = DBPhoneConfirmationViewModeCode;
        } else {
            self.errorMessage = description;
            self .mode = DBPhoneConfirmationViewModePhone;
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
            
            [_continueButton setTitle:NSLocalizedString(@"Повторить", nil) forState:UIControlStateNormal];
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
