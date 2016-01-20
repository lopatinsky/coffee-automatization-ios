//
//  DBClassLoader.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBCategoryCell;

@interface DBClassLoader : NSObject

+ (UIViewController *)loadNewOrderViewController;
+ (UIViewController *)loadSettingsViewController;


#pragma mark - Views
+ (Class)menuCategoryCell;

@end
