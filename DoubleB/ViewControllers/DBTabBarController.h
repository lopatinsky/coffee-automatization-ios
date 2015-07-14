//
//  DBTabBarController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBNewOrderViewController.h"

@interface DBTabBarController : UITabBarController<UITabBarControllerDelegate, DBNewOrderViewControllerDelegate>

+ (instancetype)sharedInstance;

- (void)awakeFromRemoteNotification;
- (void)moveToStartState;
- (void)setupViewControllers;

@end
