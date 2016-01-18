//
//  DBSettingsBaseTableViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBSettingsItem.h"

@protocol DBSettingsProtocol <NSObject>

- (id<DBSettingsItemProtocol>)settingsItem;

@end

extern NSString *const kDBSettingsNotificationsEnabled;

@interface DBSettingsBaseTableViewController : UITableViewController

@end
