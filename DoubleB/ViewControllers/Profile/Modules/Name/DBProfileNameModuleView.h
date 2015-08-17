//
//  DBProfileNameModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBProfileModuleViewProtocol.h"

@interface DBProfileNameModuleView : UIView<DBProfileModuleViewProtocol>
@property(strong, nonatomic) NSString *analyticsCategory;
@property(weak, nonatomic) id<DBProfileModuleViewDelegate> delegate;
@end
