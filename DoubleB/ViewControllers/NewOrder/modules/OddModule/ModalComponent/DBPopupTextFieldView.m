//
//  DBNOOddPopupView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 12/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBPopupTextFieldView.h"

@interface DBPopupTextFieldView ()<UITextFieldDelegate>
@property (weak, nonatomic) UIView *fromView;

@property (strong, nonatomic) UITextField *textField;
@end

@implementation DBPopupTextFieldView

- (instancetype)init {
    self = [super init];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.textField = [UITextField new];
    self.textField.delegate = self;
    self.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.f];
    [self.textField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.textField];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textField alignTop:@"8" leading:@"8" bottom:@"-8" trailing:@"-8" toView:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    return self;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.textField.text = text;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textField.placeholder = placeholder;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    _keyboardType = keyboardType;
    self.textField.keyboardType = keyboardType;
}

- (void)textFieldDidChange {
    self.text = self.textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    
    return YES;
}

- (void)showFrom:(UIView *)fromView onView:(UIView *)parentView {
    self.parentView = parentView;
    self.fromView = fromView;
    [self configOverlay];
    
    CGRect rect = [parentView convertRect:fromView.frame fromView:fromView.superview];
    self.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 45);
    [parentView addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayView.alpha = 1;
        self.alpha = 1;
    } completion:nil];
    [self.textField becomeFirstResponder];
}

- (void)hide {
    if ([self.delegate respondsToSelector:@selector(db_componentWillDismiss:)]) {
        [self.delegate db_componentWillDismiss:self];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayView.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL f){
        [self removeFromSuperview];
        [self.overlayView removeFromSuperview];
    }];
    [self.textField resignFirstResponder];
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect rect = self.frame;
                         rect.origin.y = self.parentView.frame.size.height - keyboardRect.size.height - self.frame.size.height - 1;
                         self.frame = rect;
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect rect = [self.parentView convertRect:self.fromView.frame fromView:self.fromView.superview];
                         self.frame = rect;
                     }
                     completion:nil];
}

@end
