//
//  DBGeoPushManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 28/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBPrimaryManager.h"

#import "LocationHelper.h"

@interface DBGeoPushManager : DBPrimaryManager <LocationHelperProtocol>

+ (void)handleLocalPush:(UILocalNotification *)push;

@end
