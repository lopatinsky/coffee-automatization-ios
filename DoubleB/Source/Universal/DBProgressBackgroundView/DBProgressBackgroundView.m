//
//  DBProgressBackgroundView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 04/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBProgressBackgroundView.h"

@interface DBProgressBackgroundView()
@property (weak, nonatomic) UIView *parentView;

@property (strong, nonatomic) UIImageView *overlayView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UILabel *label;
@end

@implementation DBProgressBackgroundView

- (instancetype)init {
    self = [super init];
    
    self.overlayView = [UIImageView new];
    self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.overlayView];
    [self.overlayView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    self.activityIndicator = [UIActivityIndicatorView new];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.activityIndicator];
    [self.activityIndicator alignCenterWithView:self];
    [self.activityIndicator constrainHeight:@"20"];
    [self.activityIndicator constrainWidth:@"20"];
    
    self.label = [UILabel new];
    self.label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.f];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.numberOfLines = 0;
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.label];
    [self.label alignTop:@"5" leading:@"5" bottom:@"-5" trailing:@"-5" toView:self];
    
    return self;
}

- (void)showOnViewWithBlur:(UIView *)parentView {
    UIImage *snapshot = [self.parentView snapshotImage];
    self.overlayView.image = [snapshot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    [self showOnView:parentView];
}

- (void)showOnView:(UIView *)parentView color:(UIColor *)color{
    self.overlayView.backgroundColor = color;
    self.overlayView.image = nil;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    [self showOnView:parentView];
}

- (void)showOnView:(UIView *)parentView {
    self.parentView = parentView;
    
    self.frame = parentView.bounds;
    [self layoutIfNeeded];
    
    [self startAnimating];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.parentView addSubview:self];
    [self alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.parentView];
}

- (void)hide {
    [self startAnimating];
    [self removeFromSuperview];
}

- (void)startAnimating {
    [self.activityIndicator startAnimating];
    self.label.hidden = YES;
}

- (void)stopAnimating {
    [self.activityIndicator stopAnimating];
    self.label.hidden = NO;
}

- (void)showMessage:(NSString *)message {
    [self stopAnimating];
    
    self.label.text = message;
}

@end
