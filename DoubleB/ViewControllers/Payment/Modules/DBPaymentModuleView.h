//
//  DBPaymentModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPaymentModuleView : UIView
@property (strong, nonatomic) NSString *analyticsCategory;
@property (weak, nonatomic) UIViewController *ownerViewController;

- (void)reload;
@end
