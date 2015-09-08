//
//  DBPaymentModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DBModuleView : UIView
@property (strong, nonatomic) NSString *analyticsCategory;
@property (weak, nonatomic) UIViewController *ownerViewController;

@property (strong, nonatomic) NSMutableArray *submodules;

- (void)reload;
- (void)reload:(BOOL)animated;

- (CGSize)moduleViewContentSize;
@end
