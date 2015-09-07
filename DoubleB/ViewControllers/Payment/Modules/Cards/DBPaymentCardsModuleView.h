//
//  DBPaymentCardsModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModuleView.h"

typedef NS_ENUM(NSInteger, DBPaymentCardsModuleViewMode){
    DBPaymentCardsModuleViewModeManageCards = 0,
    DBPaymentCardsModuleViewModeSelectPayment
};

@interface DBPaymentCardsModuleView : DBModuleView
@property(nonatomic, readonly) DBPaymentCardsModuleViewMode mode;

- (instancetype)initWithMode:(DBPaymentCardsModuleViewMode)mode;
@end
