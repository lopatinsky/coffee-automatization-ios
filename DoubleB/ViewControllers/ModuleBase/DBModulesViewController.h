//
//  DBModulesViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBModuleView;

@interface DBModulesViewController : UIViewController
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

@end
