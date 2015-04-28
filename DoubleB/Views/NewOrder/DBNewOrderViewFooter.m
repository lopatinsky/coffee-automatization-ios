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
#import "DBMastercardPromo.h"
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
    
//    self.freeBeverageTipView.layer.cornerRadius = self.freeBeverageTipView.frame.size.width / 2;
//    self.freeBeverageTipView.layer.masksToBounds = YES;
//    self.freeBeverageTipView.backgroundColor = [UIColor whiteColor];
//    self.freeBeverageTipView.layer.borderColor = [[UIColor db_blueColor] CGColor];
//    self.freeBeverageTipView.layer.borderWidth = 2.f;
//    
//    if([DBMastercardPromo sharedInstance].promoCurrentMugCount > 0){
//        [self.freeBeverageTipImageView templateImageWithName:@"mug"];
//        int rad = 8;
//        UILabel *mugCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.freeBeverageTipImageView.frame.size.width - rad*2, -6, rad*2, rad*2)];
//        mugCountLabel.layer.cornerRadius = rad;
//        mugCountLabel.layer.masksToBounds = YES;
//        mugCountLabel.textColor = [UIColor whiteColor];
//        mugCountLabel.backgroundColor = [UIColor blackColor];
//        mugCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.f];
//        mugCountLabel.textAlignment = NSTextAlignmentCenter;
//        mugCountLabel.text = [NSString stringWithFormat:@"%d", (int)[DBMastercardPromo sharedInstance].promoCurrentMugCount];
//        [self.freeBeverageTipImageView addSubview:mugCountLabel];
//    }
//    self.freeBeverageTipView.hidden = YES;
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
