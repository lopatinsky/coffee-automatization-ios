//
//  DBPopupViewComponent.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPopupViewComponent.h"

@interface DBPopupViewComponent ()
@property (nonatomic) DBPopupViewComponentAppearance appearance;
@property (nonatomic) DBPopupViewComponentTransition transition;
@end

@implementation DBPopupViewComponent

- (void)configOverlay {
    UIImage *snapshot = [self.parentView snapshotImage];
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

- (void)showOnView:(UIView *)parentView withAppearance:(DBPopupViewComponentAppearance)appearance;{
    [self showOnView:parentView withAppearance:appearance transition:DBPopupViewComponentTransitionBottom];
}

- (void)showOnView:(UIView *)parentView withAppearance:(DBPopupViewComponentAppearance)appearance transition:(DBPopupViewComponentTransition)transition{
    _appearance = appearance;
    _transition = transition;
    
    self.parentView = parentView;
    
    if(appearance == DBPopupViewComponentAppearancePush){
        self.frame = CGRectMake(parentView.frame.size.width, 0, parentView.frame.size.width, parentView.frame.size.height);
        
        [parentView addSubview:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.frame;
            frame.origin.x = 0;
            self.frame = frame;
        }];
    } else {
        if(transition == DBPopupViewComponentTransitionBottom) {
            [self configOverlay];
            
            CGRect rect = self.frame;
            rect.origin.y = self.overlayView.bounds.size.height;
            rect.size.width = self.overlayView.bounds.size.width;
            self.frame = rect;
            
            [self.overlayView addSubview:self];
            
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.frame;
                frame.origin.y -= self.bounds.size.height;
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
    if(_transition == DBPopupViewComponentTransitionBottom){
        [UIView animateWithDuration:0.2 animations:^{
            self.overlayView.alpha = 0;
            CGRect rect = self.frame;
            rect.origin.y = self.parentView.bounds.size.height;
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
    
    if(_appearance == DBPopupViewComponentAppearancePush) {
        [self dismiss];
    } else {
        [self hideModal];
    }
}

- (void)hideModal:(UITapGestureRecognizer *)sender{
    CGPoint touch = [sender locationInView:nil];
    
    if(!CGRectContainsPoint(self.frame, touch)){
        [self hide];
    }
}

@end
