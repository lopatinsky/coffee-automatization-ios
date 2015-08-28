//
//  DBOrderReturnView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBOrderReturnView.h"
#import "DBPopupTextView.h"

@interface DBOrderReturnView ()<UITextViewDelegate, DBPopupTextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIImageView *timeImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *venueView;
@property (weak, nonatomic) IBOutlet UIImageView *venueImageView;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;

@property (weak, nonatomic) IBOutlet UIView *changeView;
@property (weak, nonatomic) IBOutlet UIImageView *changeImageView;
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;

@property (weak, nonatomic) IBOutlet UIView *otherView;
@property (weak, nonatomic) IBOutlet UIImageView *otherImageView;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;

@property (weak, nonatomic) IBOutlet UIView *verticalSeparator;
@property (weak, nonatomic) IBOutlet UIView *horizontalSeparator;

@property (strong, nonatomic) UIImageView *overlayView;
@end

@implementation DBOrderReturnView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBOrderReturnView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    
    self.titleLabel.text = NSLocalizedString(@"Причина отмены", nil);
    
    self.horizontalSeparator.backgroundColor = [UIColor db_separatorColor];
    self.verticalSeparator.backgroundColor = [UIColor db_separatorColor];
    
    [self.timeImageView templateImageWithName:@"return_cause_time_icon"];
    [self.venueImageView templateImageWithName:@"return_cause_venue_icon"];
    [self.changeImageView templateImageWithName:@"return_cause_change_icon"];
    [self.otherImageView templateImageWithName:@"return_cause_other_icon"];
    
    self.timeLabel.text = NSLocalizedString(@"ошибся временем", nil);
    self.venueLabel.text = NSLocalizedString(@"не туда отправил", nil);
    self.changeLabel.text = NSLocalizedString(@"передумал", nil);
    self.otherLabel.text = NSLocalizedString(@"другое", nil);
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:recognizer];
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

- (void)showTextView{
    DBPopupTextView *popupTextView = [DBPopupTextView new];
    popupTextView.delegate = self;
    [popupTextView configureWithTitle:self.titleLabel.text];
    [popupTextView presentOnView:self];
}

- (void)handleOverlayTap:(UIGestureRecognizer *)recognizer{
    CGPoint touch = [recognizer locationInView:nil];
    if(!CGRectContainsPoint(self.frame, touch)){
        if([self.delegate respondsToSelector:@selector(db_orderReturnViewDidCancel:)])
            [self.delegate db_orderReturnViewDidCancel:self];
        [self hide];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer{
    CGPoint touch = [recognizer locationInView:self];
    if(CGRectContainsPoint(self.timeView.frame, touch)){
        [self.delegate db_orderReturnView:self DidSelectCause:DBOrderCancelReasonWrongTime];
    }
    if(CGRectContainsPoint(self.venueView.frame, touch)){
        [self.delegate db_orderReturnView:self DidSelectCause:DBOrderCancelReasonWrongPlace];
    }
    if(CGRectContainsPoint(self.changeView.frame, touch)){
        [self.delegate db_orderReturnView:self DidSelectCause:DBOrderCancelReasonChangeMind];
    }
    if(CGRectContainsPoint(self.otherView.frame, touch)){
        [self showTextView];
    }
}

#pragma mark - DBPopupTextViewDelegate

- (void)db_popupTextViewDidSelectDone:(DBPopupTextView *)view text:(NSString *)text{
    [self.delegate db_orderReturnView:self DidSelectOtherCause:text];
}

@end
