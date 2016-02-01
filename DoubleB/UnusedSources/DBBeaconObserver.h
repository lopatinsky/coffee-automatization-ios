//
//  DBBeaconObserver.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 24.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBBeaconObserver : NSObject

+ (void)createBeaconObserver;
+ (void)stopMonitoringRegions;

@end
