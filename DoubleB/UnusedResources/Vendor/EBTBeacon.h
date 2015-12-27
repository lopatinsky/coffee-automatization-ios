//
//  EBBeacon.h
//  EmpatikaBeaconsSDK
//
//  Copyright (c) 2014 empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLBeacon;

@interface EBTBeacon : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSNumber *major;
@property (nonatomic, strong) NSNumber *minor;
@property (nonatomic) NSInteger proximity;
@property (nonatomic) double accuracy;

- (id)initWithBeacon:(CLBeacon *)beacon;
+ (NSArray *)beaconsFromCLBeacons:(NSArray *)beacons;

@end
