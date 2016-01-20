//
//  DBDemoLoginViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBDemoLoginViewController;
@protocol DBDemoLoginViewControllerDelegate <NSObject>
- (void)db_demoLoginVCLoggedIn:(DBDemoLoginViewController *)controller;
@end

@interface DBDemoLoginViewController : UIViewController
@property (weak, nonatomic) id<DBDemoLoginViewControllerDelegate> delegate;
@end
