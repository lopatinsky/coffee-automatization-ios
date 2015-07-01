//
//  DBNewOrderViewFooter.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBNewOrderViewFooter.h"
#import "OrderManager.h"
#import "Compatibility.h"
#import "DBDiscountMessageCell.h"


@interface DBNewOrderViewFooter ()<UIGestureRecognizerDelegate>
@end

@implementation DBNewOrderViewFooter

- (void)awakeFromNib{
    self.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    self.labelAddress.text = @"";
    
    self.activityIndicator.hidesWhenStopped = YES;
    
    //Hide Free Beverage tip
    self.freeBeverageTipView.hidden = YES;

    [self configureStyling];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureStyling {
    [self.freeBeverageTipImageView templateImageWithName:@"mug"];
    [self.venueImageView templateImageWithName:@"venue"];
    [self.clockImageView templateImageWithName:@"clock"];
    [self.profileImageView templateImageWithName:@"profile"];
    [self.paymentImageView templateImageWithName:@"payment"];
    [self.commentImageView templateImageWithName:@"comment"];
    [self.disclosureIndicatorAddress templateImageWithName:@"arrow"];
    [self.disclosureIndicatorTime templateImageWithName:@"arrow"];
    [self.disclosureIndicatorProfile templateImageWithName:@"arrow"];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self];
    
    if([self point:point insideView:self.disclosureIndicatorAddress]){
    }
    
    if([self point:point insideView:self.disclosureIndicatorTime]){
    }
    
    if([self point:point insideView:self.disclosureIndicatorProfile]){
    }
    return YES;
}

- (BOOL)point:(CGPoint)point insideView:(UIView *)view{
    CGRect rect = [self convertRect:view.frame fromView:view.superview];
    
    return CGRectContainsPoint(rect, point);
}

//- (void)showFreeBeverageTip{
//    self.freeBeverageTipView.hidden = NO;
//    self.freeBeverageTipView.alpha = 0;
//    [UIView animateWithDuration:0.2 animations:^{
//        self.freeBeverageTipView.alpha = 1.f;
//    }];
//    
//}
//
//- (void)hideFreeBeverageTip{
//    [UIView animateWithDuration:0.2 animations:^{
//        self.freeBeverageTipView.alpha = 0;
//    } completion:^(BOOL finished) {
//        self.freeBeverageTipView.hidden = YES;
//    }];
//}




@end
