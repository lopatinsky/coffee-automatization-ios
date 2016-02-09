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
@property (weak, nonatomic) IBOutlet UIView *closeView;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation DBPopupTextFieldView

+ (DBPopupTextFieldView *)create {
    DBPopupTextFieldView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBPopupTextFieldView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    
    @weakify(self)
    [self.closeView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self hide];
    }]];
    
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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
    [self hide];
    
    return YES;
}

- (void)moveY:(double)origin {
    CGRect rect = self.frame;
    rect.origin.y = origin - self.textField.frame.origin.y;
    self.frame = rect;
}

- (void)showFrom:(UIView *)fromView onView:(UIView *)parentView {
    self.parentView = parentView;
    self.fromView = fromView;
    [self configOverlay];
    
    CGRect rect = [parentView convertRect:fromView.frame fromView:fromView.superview];
    self.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.frame.size.height);
    [self moveY:rect.origin.y];
    
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
                         [self moveY:rect.origin.y];
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect rect = [self.parentView convertRect:self.fromView.frame fromView:self.fromView.superview];
                         [self moveY:rect.origin.y];
                     }
                     completion:nil];
}

@end
