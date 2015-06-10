//
//  DBNewOrderItemErrorView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 05.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBNewOrderItemErrorView.h"

#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>

@interface DBNewOrderItemErrorView ()
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *transparentView;

@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *alarmImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContentViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContentViewLeading;

@end

@implementation DBNewOrderItemErrorView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNewOrderItemErrorView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    
    self.contentView.userInteractionEnabled = YES;
    @weakify(self)
    [self.contentView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if([self.delegate respondsToSelector:@selector(db_newOrderItemErrorViewDidTap:)]){
            [self.delegate db_newOrderItemErrorViewDidTap:self];
        }
    }]];
    
    [self.actionButton setBackgroundColor:[UIColor db_defaultColor]];
    [self.actionButton addTarget:self action:@selector(actionButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.indicatorView.backgroundColor = [UIColor colorWithRed:243./255 green:115./255 blue:50./255 alpha:1.0];
}

- (void)setMode:(DBNewOrderItemErrorViewMode)mode{
    _mode = mode;
    
    if(mode == DBNewOrderItemErrorViewModeDelete){
        [self.actionButton setTitle:NSLocalizedString(@"Удалить", nil) forState:UIControlStateNormal];
    } else {
        [self.actionButton setTitle:NSLocalizedString(@"Заменить", nil) forState:UIControlStateNormal];
    }
}

- (void)setMessage:(NSString *)message{
    _message = message;
    
    self.messageLabel.text = message;
}

- (BOOL)isOpen{
    return !self.constraintContentViewLeading.constant == 0;
}

- (void)actionButtonClick{
    if([self.delegate respondsToSelector:@selector(db_newOrderItemErrorView:didSelectAction:)]){
        [self.delegate db_newOrderItemErrorView:self didSelectAction:self.mode];
    }
}

- (void)moveContentLeft{
    [UIView animateWithDuration:0.3 animations:^{
        self.constraintContentViewLeading.constant = -self.actionButton.frame.size.width;
        self.constraintContentViewTrailing.constant = self.actionButton.frame.size.width;
        [self layoutIfNeeded];
    }];
}

- (void)moveContentRight{
    [UIView animateWithDuration:0.3 animations:^{
        self.constraintContentViewLeading.constant = 0;
        self.constraintContentViewTrailing.constant = 0;
        [self layoutIfNeeded];
    }];
}

- (void)showOnView:(UIView *)view inFrame:(CGRect)rect{
    if(self.superview == nil){
        UIImage *backImage = [view snapshotImageOfFrame:rect];
        self.backImageView.image = backImage;
        
        self.frame = rect;
        [self moveContentRight];
        [view addSubview:self];
    }
}

- (void)hide{
    [self moveContentRight];
    [self removeFromSuperview];
}

@end
