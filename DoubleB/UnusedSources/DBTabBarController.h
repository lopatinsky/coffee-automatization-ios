//
//  DBTabBarController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBNewOrderViewController.h"


@interface DBTabBarController : UITabBarController

+ (instancetype)sharedInstance;

- (BOOL)tabAtIndexEnabled:(NSUInteger)index;

- (void)moveToStartState;
- (void)awakeFromRemoteNotification;

@end
