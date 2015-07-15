//
//  DBPositionViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionsViewControllerDelegate.h"

@class DBMenuPosition;

typedef NS_ENUM(NSUInteger, DBPositionViewControllerMode) {
    DBPositionViewControllerModeMenuPosition = 0,
    DBPositionViewControllerModeOrderPosition
};

@interface DBPositionViewController : UIViewController
@property (strong, nonatomic) DBMenuPosition *position;
@property (nonatomic) DBPositionViewControllerMode mode;
@property (weak, nonatomic) UINavigationController *parentNavigationController;

- (instancetype)initWithPosition:(DBMenuPosition *)position mode:(DBPositionViewControllerMode)mode;
@end
