//
//  DBPaymentCardAdditionModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPaymentModuleViewProtocol.h"

@interface DBPaymentCardAdditionModuleView : UIView<DBPaymentModuleViewProtocol>
@property(strong, nonatomic) NSString *analyticsCategory;
@property(weak, nonatomic) id<DBPaymentModuleViewDelegate> delegate;
@end
