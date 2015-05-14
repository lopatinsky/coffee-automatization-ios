//
//  DBPositionViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuPosition;

typedef NS_ENUM(NSUInteger, DBPositionViewControllerMode) {
    DBPositionViewControllerModeMenuPosition = 0,
    DBPositionViewControllerModeOrderPosition
};

@interface DBPositionViewController : UIViewController
@property (strong, nonatomic) DBMenuPosition *position;
@property (nonatomic) DBPositionViewControllerMode mode;

//- (instancetype)initWithPosition:(DBMenuPosition *)position mode:(DBPositionViewControllerMode)mode;
- (instancetype)initWithPosition:(DBMenuPosition *)position mode:(DBPositionViewControllerMode)mode navigationController:(UINavigationController *)navigationController;
@end
