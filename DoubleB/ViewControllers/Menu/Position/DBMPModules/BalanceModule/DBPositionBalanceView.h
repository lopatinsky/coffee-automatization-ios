//
//  DBPositionBalanceViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPopupViewController.h"

@interface DBPositionBalanceView : UIView<DBPopupViewControllerContent>

@property (strong, nonatomic) DBMenuPosition *position;

- (void)reload;

@end
