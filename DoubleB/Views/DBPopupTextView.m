//
//  DBPopupTextView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPopupTextView.h"

#import "UIGestureRecognizer+BlocksKit.h"

@interface DBPopupTextView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;

@end

@implementation DBPopupTextView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPopupTextView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor whiteColor];
    
    self.doneLabel.textColor = [UIColor db_defaultColor];
    [self.backImageView templateImageWithName:@"back_arrow_icon"];
    
    @weakify(self);
    self.doneLabel.userInteractionEnabled = YES;
    [self.doneLabel addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        [self.delegate db_popupTextViewDidSelectDone:self text:self.textView.text];
    }]];
    
    self.backImageView.userInteractionEnabled = YES;
    [self.backImageView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        [self.textView resignFirstResponder];
        [self dismiss];
        if([self.delegate respondsToSelector:@selector(db_popupTextViewDidSelectCancel:)]){
            [self.delegate db_popupTextViewDidSelectCancel:self];
        }
    }]];
}

- (void)configureWithTitle:(NSString *)title{
    self.titleLabel.text = title;
}

- (void)presentOnView:(UIView *)view{
    CGRect rect = view.bounds;
    rect.origin.x = view.frame.size.width;
    
    self.frame = rect;
    [view addSubview:self];
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.frame;
        rect.origin.x = 0;
        self.frame = rect;
    } completion:^(BOOL finished) {
        [self.textView becomeFirstResponder];
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.frame;
        rect.origin.x = rect.size.width;
        self.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
