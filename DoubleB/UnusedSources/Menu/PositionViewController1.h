//
//  DBPositionViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionViewControllerProtocol.h"

@class DBMenuPosition;

@interface PositionViewController1 : UIViewController
@property (strong, nonatomic) DBMenuPosition *position;
@property (nonatomic) PositionViewControllerMode mode;
@property (weak, nonatomic) UINavigationController *parentNavigationController;

@end
