//
// Created by Sergey Pronin on 7/14/13.
// Copyright (c) 2013 Bingo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreLocation/CoreLocation.h>
#import "LocationHelper.h"

#import "DBGeoPushManager.h"


NSString *const kLocationChangedNotification = @"kLocationChanged";
NSString *const kLocationManagerStatusAuthorized = @"kLocationManagerStatusAuthorized";

#define LOCATION_CACHE_TIME 5*60.f

@interface LocationHelper() <CLLocationManagerDelegate>
@property (nonatomic, strong) NSDate *lastLocationDate;
@end


@implementation LocationHelper {
}

-(void)dealloc {
    [self.locationManager stopUpdatingLocation];
}

+(id)sharedInstance {
    static dispatch_once_t once;
    static LocationHelper *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

-(id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self;
    }
    return self;
}

-(BOOL)isDenied {
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied;
}

-(BOOL)isAuthorized {
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
}

- (void)requestPermission {
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]
        && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

-(void)startUpdatingLocation {
    /*if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]
     && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
     [self.locationManager requestWhenInUseAuthorization];
     } else {
     [self.locationManager startUpdatingLocation];
     }*/
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]
        && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

/**
 * Check if last location < 5 min ago
 */
- (CLLocation *)cachedLocationIfAvailable {
    NSDate *now = [NSDate date];
    
    if ([now timeIntervalSinceDate:self.lastLocationDate] < LOCATION_CACHE_TIME && self.lastLocation) {
        return self.lastLocation;
    }
    
    return nil;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [[DBGeoPushManager sharedInstance] didEnter:region];
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //    [[DBGeoPushManager sharedInstance] didEnter:region];
}

- (void)updateLocationWithCallback:(void (^)(CLLocation *location))callback {
    CLLocation *cached = [self cachedLocationIfAvailable];
    if (cached) {
        if (callback) {
            callback(cached);
        }
    } else {
        self.callback = callback;
    }
    
    [self startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.lastLocation = [locations lastObject];
    self.lastLocationDate = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationChangedNotification object:self.lastLocation];
    
    if (self.callback) {
        self.callback(self.lastLocation);
        self.callback = nil;
    }
    
    [self.locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            if (self.callback) {
                self.callback(nil);
                self.callback = nil;
            }
            break;
        default:
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerStatusAuthorized object:nil];
            //            [self.locationManager startUpdatingLocation];
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if (self.callback) {
        self.callback(nil);
        self.callback = nil;
    }
    
}

@end