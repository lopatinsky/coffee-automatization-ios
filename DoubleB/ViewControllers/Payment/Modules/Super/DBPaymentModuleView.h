//
//  DBPaymentModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"
#import "Order.h"

@class DBPaymentModuleView;

@protocol DBPaymentModuleViewDelegate <NSObject>

@required
- (void)db_paymentModuleDidSelectPaymentType:(PaymentType)paymentType;

@end

@interface DBPaymentModuleView : DBModuleView
@property (weak, nonatomic) id<DBPaymentModuleViewDelegate> delegate;
@end
