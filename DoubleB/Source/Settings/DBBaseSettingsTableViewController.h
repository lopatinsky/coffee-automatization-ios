//
//  DBSettingsBaseTableViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBSettingsItem.h"

extern NSString *const kDBSettingsNotificationsEnabled2;

@class DBBaseSettingsTableViewController;

@protocol DBSettingsProtocol <NSObject>
@optional
+ (id<DBSettingsItemProtocol>)settingsItem;
+ (id<DBSettingsItemProtocol>)settingsItem:(DBBaseSettingsTableViewController*)settingsVC;

- (id<DBSettingsItemProtocol>)settingsItem;
- (id<DBSettingsItemProtocol>)settingsItem:(DBBaseSettingsTableViewController*)settingsVC;
@end

@interface DBBaseSettingsTableViewController : UITableViewController

- (NSMutableArray<DBSettingsItemProtocol> *)settingsItems;
- (void)reload;

@end
