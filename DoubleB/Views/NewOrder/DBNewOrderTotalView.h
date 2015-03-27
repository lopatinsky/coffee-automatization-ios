//
//  DBNewOrderTotalView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBNewOrderTotalView : UIView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *totalRefreshControl;
@property (weak, nonatomic) IBOutlet UILabel *labelTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelActualTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelOldTotal;

- (void)startUpdating;
- (void)endUpdating;

@end
