//
// Created by Sergey Pronin on 5/29/14.
// Copyright (c) 2014 Sergey Pronin. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kLocationChangedNotification;

/**
* Helps get location in singleton way
*/
@protocol LocationHelperProtocol <NSObject>

- (void)didEnter:(CLRegion *)region;

@end


@interface LocationHelper : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isDenied;
- (BOOL)isAuthorized;
- (void)requestPermission;
- (void)startUpdatingLocation;

/**
* Async get location
*/
- (void)updateLocationWithCallback:(void(^)(CLLocation *location))callback;

@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void(^callback)(id);

@end