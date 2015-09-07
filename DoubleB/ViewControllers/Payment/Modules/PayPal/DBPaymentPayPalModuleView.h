//
//  DBPaymentCashModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModuleView.h"

typedef NS_ENUM(NSInteger, DBPaymentPayPalModuleViewMode) {
    DBPaymentPayPalModuleViewModePaymentType = 0,
    DBPaymentPayPalModuleViewModeManageAccount
};

@interface DBPaymentPayPalModuleView : DBModuleView
@property (nonatomic) DBPaymentPayPalModuleViewMode mode;
@end
