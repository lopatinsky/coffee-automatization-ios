//
//  DBClassLoader.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBSettingsTableViewController;
@class DBNewOrderViewController;

@interface DBClassLoader : NSObject

+ (DBNewOrderViewController *)loadNewOrderViewController;
+ (DBSettingsTableViewController *)loadSettingsViewController;

@end
