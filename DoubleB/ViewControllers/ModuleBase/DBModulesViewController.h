//
//  DBModulesViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBModulesViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *modules;

- (void)layoutModules;
- (void)reloadModules:(BOOL)animated;

@end