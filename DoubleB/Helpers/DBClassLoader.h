//
//  DBClassLoader.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBSettingsTableViewController;

@class DBCategoryCell;

@interface DBClassLoader : NSObject

+ (UIViewController *)loadNewOrderViewController;
+ (DBSettingsTableViewController *)loadSettingsViewController;


#pragma mark - Views
+ (Class)menuCategoryCell;

@end
