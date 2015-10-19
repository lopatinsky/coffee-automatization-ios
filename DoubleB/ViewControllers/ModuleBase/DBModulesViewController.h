//
//  DBModulesViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModuleView.h"

@interface DBModulesViewController : UIViewController<DBModuleViewDelegate>
@property (strong, nonatomic) NSString *analyticsCategory;

/**
 * Array of modules
 * Use addModule method to automaticaly set all settings for module
 */
@property (strong, nonatomic) NSMutableArray *modules;

- (void)addModule:(DBModuleView *)moduleView;
- (void)removeModule:(DBModuleView *)moduleView;

- (void)layoutModules;
- (void)reloadModules:(BOOL)animated;

/**
 * return view where moduleView will display modal component
 * Override this method to customize appearance
 */
- (UIView *)containerForModuleModalComponent:(DBModuleView *)view;

@end
