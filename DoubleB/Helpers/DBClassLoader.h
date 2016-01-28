//
//  DBClassLoader.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBNewOrderVC.h"
#import "DBCategoryCell.h"

@class DBCompanySettingsViewController;
@class DBStartNavController;
@class DBNewOrderVC;
@class DBCategoryCell;


@interface DBClassLoader : NSObject

+ (DBStartNavController *)loadStartNavigationController;
+ (DBNewOrderVC *)loadNewOrderVC;
+ (DBCompanySettingsViewController *)loadSettingsViewController;

+ (Class<DBCategoryCellProtocol>)loadCategoryCell;

@end
