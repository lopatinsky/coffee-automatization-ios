//
//  DBPaymentViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModulesViewController.h"
#import "DBBaseSettingsTableViewController.h"

typedef NS_ENUM(NSInteger, DBPaymentViewControllerMode) {
    DBPaymentViewControllerModeSettings = 0,
    DBPaymentViewControllerModeChoosePayment
};

@interface DBPaymentViewController : DBModulesViewController <DBSettingsProtocol>
@property (nonatomic) DBPaymentViewControllerMode mode;

/**
 * List of payment types available on screen. If nothing specified, in use all types
 */
@property (strong, nonatomic) NSArray *paymentTypes;
@end
