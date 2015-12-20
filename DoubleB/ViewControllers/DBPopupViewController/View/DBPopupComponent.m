//
//  DBPopupViewComponent.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPopupComponent.h"

@interface DBPopupComponent ()
@property (nonatomic) DBPopupAppearance appearance;
@property (nonatomic) DBPopupTransition transition;
@property (nonatomic) CGFloat offset;
@end

@implementation DBPopupComponent

- (void)configOverlay {
    [self configOverlay:self.parentView.bounds];
}

- (void)configOverlay:(CGRect)rect {
    UIImage *snapshot = [self.parentView snapshotImageOfFrame:rect];
    self.overlayView = [[UIImageView alloc] initWithFrame:self.parentView.bounds];
    self.overlayView.image = [snapshot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
    self.overlayView.alpha = 0;
    self.overlayView.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideModal:)];
    recognizer.cancelsTouchesInView = NO;
    [self.overlayView addGestureRecognizer:recognizer];
    [self.parentView addSubview:self.overlayView];
}

#pragma mark - Push appearance

- (void)showOnView:(UIView *)parentView appearance:(DBPopupAppearance)appearance {
    [self showOnView:parentView appearance:appearance transition:DBPopupTransitionCenter];
}

- (void)showOnView:(UIView *)parentView
        appearance:(DBPopupAppearance)appearance
        transition:(DBPopupTransition)transition;{
    [self showOnView:parentView appearance:appearance transition:transition offset:0];
}

- (void)showOnView:(UIView *)parentView
        appearance:(DBPopupAppearance)appearance
        transition:(DBPopupTransition)transition
            offset:(CGFloat)offset {
    _appearance = appearance;
    _transition = transition;
    _offset = offset;
    
    _presented = YES;
    
    self.parentView = parentView;
    
    if(appearance == DBPopupAppearancePush){
        self.frame = CGRectMake(parentView.frame.size.width, 0, parentView.frame.size.width, parentView.frame.size.height);
        
        [parentView addSubview:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.frame;
            frame.origin.x = 0;
            self.frame = frame;
        }];
    } else {
        [self configOverlay];
        if(transition == DBPopupTransitionBottom) {
            CGRect rect = self.frame;
            rect.origin.y = self.overlayView.bounds.size.height - _offset;
            rect.size.width = self.overlayView.bounds.size.width;
            self.frame = rect;
            
            [self.parentView addSubview:self];
            
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.frame;
                frame.origin.y -= self.bounds.size.height;
                self.frame = frame;
                
                self.overlayView.alpha = 1;
            }];
        }
        
        if(transition == DBPopupTransitionTop) {
            CGRect rect = self.frame;
            rect.origin.y = -rect.size.height + _offset;
            rect.size.width = self.overlayView.bounds.size.width;
            self.frame = rect;
            
            [self.parentView addSubview:self];
            
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.frame;
                frame.origin.y += self.bounds.size.height;
                self.frame = frame;
                
                self.overlayView.alpha = 1;
            }];
        }
    }
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.frame;
        rect.origin.x = self.parentView.frame.size.width;
        self.frame = rect;
    } completion:^(BOOL f){
        [self removeFromSuperview];
    }];
}

- (void)hideModal{
    if(_transition == DBPopupTransitionBottom){
        [UIView animateWithDuration:0.2 animations:^{
            self.overlayView.alpha = 0;
            CGRect rect = self.frame;
            rect.origin.y = self.parentView.bounds.size.height - _offset;
            self.frame = rect;
        } completion:^(BOOL f){
            [self removeFromSuperview];
            [self.overlayView removeFromSuperview];
        }];
    }
    
    if(_transition == DBPopupTransitionTop){
        [UIView animateWithDuration:0.2 animations:^{
            self.overlayView.alpha = 0;
            CGRect rect = self.frame;
            rect.origin.y = -rect.size.height + _offset;
            self.frame = rect;
        } completion:^(BOOL f){
            [self removeFromSuperview];
            [self.overlayView removeFromSuperview];
        }];
    }
}

- (void)hide {
    if ([self.delegate respondsToSelector:@selector(db_componentWillDismiss:)]) {
        [self.delegate db_componentWillDismiss:self];
    }
    
    if(_appearance == DBPopupAppearancePush) {
        [self dismiss];
    } else {
        [self hideModal];
    }
    
    _presented = NO;
}

- (void)hideModal:(UITapGestureRecognizer *)sender{
    CGPoint touch = [sender locationInView:nil];
    
    if(!CGRectContainsPoint(self.frame, touch)){
        [self hide];
    }
}

@end
