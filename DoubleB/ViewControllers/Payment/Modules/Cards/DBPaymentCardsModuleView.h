//
//  DBPaymentCardsModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPaymentModuleView.h"

typedef NS_ENUM(NSInteger, DBPaymentCardsModuleViewMode){
    DBPaymentCardsModuleViewModeManageCards = 0,
    DBPaymentCardsModuleViewModeSelectCardPayment
};

@interface DBPaymentCardsModuleView : DBPaymentModuleView
@property(nonatomic) DBPaymentCardsModuleViewMode mode;
@end
