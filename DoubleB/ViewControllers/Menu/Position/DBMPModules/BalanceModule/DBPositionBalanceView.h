//
//  DBPositionBalanceViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPositionBalanceView : UIView

@property (strong, nonatomic) DBMenuPosition *position;

- (void)reload;

@end
