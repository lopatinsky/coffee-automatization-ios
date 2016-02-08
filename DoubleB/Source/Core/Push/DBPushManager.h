//
//  DBPushManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"

@interface DBPushManager : DBPrimaryManager

- (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)registerForNotifications;
- (void)subscribeToChannel:(NSString *)channel force:(BOOL)force;

@end
