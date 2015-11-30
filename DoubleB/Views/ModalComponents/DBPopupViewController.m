//
//  DBPopupViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPopupViewController.h"
#import "DBPositionBalanceView.h"

#import "UIView+RoundedCorners.h"

@interface DBPopupViewController()
@property (weak, nonatomic) IBOutlet UIImageView *overlayView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContentViewHeight;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) UIView *parentView;


@end

@implementation DBPopupViewController

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPopupViewController" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [self.doneButton setBackgroundColor:[UIColor db_defaultColor]];
    [self.doneButton setRoundedCorners];
    [self.doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView setRoundedCorners];
}

- (void)setComponentView:(UIView *)componentView {
    if (componentView) {
        if (_componentView) {
            [_componentView removeFromSuperview];
        }
        
        _componentView = componentView;
        [self.contentView addSubview:_componentView];
        _componentView.translatesAutoresizingMaskIntoConstraints = NO;
        [_componentView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.contentView];
    }
}

- (void)doneButtonClick {
    [self hide];
}

#pragma mark - Appearance

- (void)configOverlay {
    [self configOverlay:self.parentView.bounds];
}

- (void)configOverlay:(CGRect)rect {
    UIImage *snapshot = [self.parentView snapshotImageOfFrame:rect];
    self.overlayView.image = [snapshot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
    self.overlayView.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    recognizer.cancelsTouchesInView = NO;
    [self.overlayView addGestureRecognizer:recognizer];
}

- (void)showOnView:(UIView *)parentView {
    self.parentView = parentView;
    
    [self configOverlay];
    [(DBPositionBalanceView *)_componentView reload];
    
    CGRect rect = self.frame;
    rect.size.width = self.parentView.bounds.size.width;
    rect.size.height = self.parentView.bounds.size.height;
    self.frame = rect;
    
    self.alpha = 0;
    [self.parentView addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
}

- (void)hide{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
