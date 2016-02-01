//
//  DBMenuViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBMenuViewControllerType) {
    DBMenuViewControllerTypeInitial = 0,
    DBMenuViewControllerTypeSecond
};

typedef NS_ENUM(NSInteger, DBMenuViewControllerMode) {
    DBMenuViewControllerModeCategoriesAndPositions = 0,
    DBMenuViewControllerModeCategories,
    DBMenuViewControllerModePositions
};

@class DBMenuCategory;
@interface DBMenuViewController : UIViewController
@property (nonatomic) DBMenuViewControllerType type;
@property (nonatomic, readonly) DBMenuViewControllerMode mode;
@property (strong, nonatomic) DBMenuCategory *category;
@end
