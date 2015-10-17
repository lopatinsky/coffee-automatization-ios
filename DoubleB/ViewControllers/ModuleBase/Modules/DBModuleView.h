//
//  DBPaymentModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DBModuleView : UIView
// Category for analytics
@property (strong, nonatomic) NSString *analyticsCategory;

// Controller which hold module
@property (weak, nonatomic) UIViewController *ownerViewController;

// Array of submodules
@property (strong, nonatomic) NSMutableArray *submodules;

// Use only if you set modules from code;
- (void)layoutModules;

/**
 * Reload content of module and all submodules. Recalculate size
 */
- (void)reload:(BOOL)animated;

/**
 * Animated reload
 * Not override this method. Use it only for react on notifications
 */
- (void)reload;

/**
 * Returns content size of current module. By default returns frame size
 * Override it to customize module size
 */
- (CGSize)moduleViewContentSize;

/**
 * Invokes when get touch on self
 * Override to customize touch actions
 */
- (void)touchAtLocation:(CGPoint)location;
@end
