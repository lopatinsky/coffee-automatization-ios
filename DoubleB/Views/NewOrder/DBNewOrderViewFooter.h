//
//  DBNewOrderViewFooter.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 16.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBNewOrderViewFooter : UIView
@property (weak, nonatomic) IBOutlet UIButton *venueButton;
@property (weak, nonatomic) IBOutlet UIButton *readyTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *paymentButton;
@property (weak, nonatomic) IBOutlet UIView *freeBeverageTipView;
@property (weak, nonatomic) IBOutlet UIImageView *freeBeverageTipImageView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelCard;
@property (weak, nonatomic) IBOutlet UILabel *labelComment;

@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicatorAddress;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicatorTime;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicatorProfile;

@property (weak, nonatomic) IBOutlet UIImageView *venueImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clockImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *paymentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;

//- (void)showFreeBeverageTip;
//- (void)hideFreeBeverageTip;

@end
