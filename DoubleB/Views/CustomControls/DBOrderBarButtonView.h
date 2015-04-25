//
//  DBOrderBarButtonView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBOrderBarButtonView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBackImageViewWidth;
@property (weak, nonatomic) IBOutlet UIImageView *orderImageView;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@end
