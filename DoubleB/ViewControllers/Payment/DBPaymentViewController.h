//
//  DBPaymentViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModulesViewController.h"

typedef NS_ENUM(NSInteger, DBPaymentViewControllerMode) {
    DBPaymentViewControllerModeManage = 0,
    DBPaymentViewControllerModeChoosePayment
};

@interface DBPaymentViewController : DBModulesViewController
@property (nonatomic) DBPaymentViewControllerMode mode;
@end
