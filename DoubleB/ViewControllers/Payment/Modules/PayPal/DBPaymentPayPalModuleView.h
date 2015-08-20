//
//  DBPaymentCashModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPaymentModuleView.h"

typedef NS_ENUM(NSInteger, DBPaymentPayPalModuleViewMode) {
    DBPaymentPayPalModuleViewModePaymentType = 0,
    DBPaymentPayPalModuleViewModeManageAccount
};

@interface DBPaymentPayPalModuleView : DBPaymentModuleView
@property (nonatomic) DBPaymentPayPalModuleViewMode mode;
@end
