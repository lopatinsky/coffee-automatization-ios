//
//  DBPaymentCardsModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPaymentModuleViewProtocol.h"

typedef NS_ENUM(NSInteger, DBPaymentCardsModuleViewMode){
    DBPaymentCardsModuleViewModeManageCards,
    DBPaymentCardsModuleViewModeSelectCard
};

@interface DBPaymentCardsModuleView : UIView<DBPaymentModuleViewProtocol>
@property(strong, nonatomic) NSString *analyticsCategory;
@property(weak, nonatomic) id<DBPaymentModuleViewDelegate> delegate;

@property(nonatomic) DBPaymentCardsModuleViewMode mode;
@end
