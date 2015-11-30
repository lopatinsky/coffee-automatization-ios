//
//  DBPopupViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPopupViewController : UIView

@property (strong, nonatomic) UIView *componentView;

- (void)showOnView:(UIView *)parentView;

@end
