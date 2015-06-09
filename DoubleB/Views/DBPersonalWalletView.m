//
//  DBPersonalWalletView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPersonalWalletView.h"
#import "DBPromoManager.h"
#import "Compatibility.h"

@interface DBPersonalWalletView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *buttonSeparatorView;

@property (strong, nonatomic) UIImageView *overlayView;

@end

@implementation DBPersonalWalletView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPersonalWalletView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    
    self.balanceLabel.textColor = [UIColor db_defaultColor];
    
    self.buttonSeparatorView.backgroundColor = [UIColor db_separatorColor];
    
    self.activityIndicator.hidesWhenStopped = YES;
    
    [self reloadAppearance];
}

- (void)reload{
    [self.activityIndicator startAnimating];
    
    [[DBPromoManager sharedManager] updatePersonalWalletBalance:^(double balance) {
        [self.activityIndicator stopAnimating];
        
        [self reloadAppearance];
        
        if([self.delegate respondsToSelector:@selector(db_personalWalletView:didUpdateBalance:)]){
            [self.delegate db_personalWalletView:self didUpdateBalance:balance];
        }
    }];
}

- (void)reloadAppearance{
    self.balanceLabel.text = [NSString stringWithFormat:@"%.1f", [DBPromoManager sharedManager].walletBalance];
    
    if([DBPromoManager sharedManager].walletTextDescription.length > 0){
        self.titleLabel.text = [DBPromoManager sharedManager].walletTextDescription;
    } else {
        self.titleLabel.text = @"Баланс вашего персонального счета";
    }
}

- (void)showOnView:(UIView *)view{
    self.overlayView = [[UIImageView alloc] initWithFrame:view.bounds];
    self.overlayView.image = [[view snapshotImage] applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
    self.overlayView.alpha = 0;
    self.overlayView.userInteractionEnabled = YES;
    [self.overlayView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(handleOverlayTap:)]];
    [view addSubview:self.overlayView];
    
    CGRect rect = self.frame;
    rect.origin.x = (view.frame.size.width - rect.size.width) / 2;
    rect.origin.y = (view.frame.size.height - rect.size.height) / 2;
    self.frame = rect;
    
    UIImageView *selfSnapshot = [[UIImageView alloc] initWithFrame:self.frame];
    selfSnapshot.image = [self snapshotImage];
    
    [view addSubview:selfSnapshot];
    selfSnapshot.alpha = 0;
    
    [UIView animateWithDuration:0.08
                     animations:^{
                         selfSnapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                         selfSnapshot.alpha = 0.8;
                         self.overlayView.alpha = 0.8;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.12
                                          animations:^{
                                              selfSnapshot.transform = CGAffineTransformIdentity;
                                              selfSnapshot.alpha = 1.0;
                                              self.overlayView.alpha = 1.0;
                                          } completion:^(BOOL finished) {
                                              [view addSubview:self];
                                              [selfSnapshot removeFromSuperview];
                                          }];
                     }];
    
    [self reload];
}

- (void)hide{
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayView.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL f){
        [self.overlayView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)handleOverlayTap:(UIGestureRecognizer *)recognizer{
    CGPoint touch = [recognizer locationInView:nil];
    if(!CGRectContainsPoint(self.frame, touch)){
        [self hide];
    }
}

- (IBAction)doneButtonClick:(id)sender {
    [self hide];
}

@end
