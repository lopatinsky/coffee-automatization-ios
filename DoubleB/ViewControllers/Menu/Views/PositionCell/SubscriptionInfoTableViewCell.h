//
//  SubscriptionInfoTableViewCell.h
//  DoubleB
//
//  Created by Balaban Alexander on 21/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriptionInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberOfDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCupsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cupImage;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property (weak, nonatomic) UIViewController *delegate;
@property (weak, nonatomic) IBOutlet UILabel *subscriptionAds;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@end