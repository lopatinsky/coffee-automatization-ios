//
//  DBStartNavController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBStartNavController;
@protocol DBStartNavControllerDelegate <NSObject>
- (void)db_startNavVCNeedsMoveToMain:(UIViewController *)controller;
@end

@interface DBStartNavController : UINavigationController
@property (weak, nonatomic) id<DBStartNavControllerDelegate> navDelegate;

- (instancetype)initWithDelegate:(id<DBStartNavControllerDelegate>)navDelegate;

@end
