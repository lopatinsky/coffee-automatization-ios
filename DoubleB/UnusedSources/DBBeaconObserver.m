//
//  DBBeaconObserver.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 24.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBBeaconObserver.h"
#import "EBTBeaconsTracker.h"
#import "LocationHelper.h"

@implementation DBBeaconObserver

+ (void)createBeaconObserver{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[EBTBeaconsTracker sharedInstance] setAppID:@"6666"];
        [[EBTBeaconsTracker sharedInstance] enableRules];
        [[EBTBeaconsTracker sharedInstance] setUuids:@[
                                                       @"EBEFD083-70A2-47C8-9837-E7B5634DF527",
                                                       @"B9407F30-F5F8-466E-AFF9-25556B57FE6D",
                                                       @"808CEA56-16A6-4788-BF4E-E337335DD6BA"
                                                       ]];
        [EBTBeaconsTracker sharedInstance].disableBluetoothDialog = YES;
        [[EBTBeaconsTracker sharedInstance] startMonitoring];
        
        [[LocationHelper sharedInstance] requestPermission];
    });
}

+ (void)stopMonitoringRegions{
    [[EBTBeaconsTracker sharedInstance] stopMonitoringRegions];
}

@end
