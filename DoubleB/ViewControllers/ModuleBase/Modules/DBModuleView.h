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

// Use only if you set modules from code;
- (void)layoutModules;

- (void)reload;
- (void)reload:(BOOL)animated;

- (CGSize)moduleViewContentSize;
- (void)touchAtLocation:(CGPoint)location;
@end
