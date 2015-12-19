//
//  DBGeoPushManager.m
//  DoubleB
//
//  Created by Balaban Alexander on 28/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBGeoPushManager.h"
#import "DBGeoPush.h"

#import "DBAPIClient.h"

#import <CoreLocation/CoreLocation.h>

@interface DBGeoPushManager()

@property (nonatomic) BOOL enabled;
@property (nonatomic, strong) DBGeoPush *geoPush;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation DBGeoPushManager

- (instancetype)init {
    self = [super init];
    
    self.enabled = [[DBGeoPushManager valueForKey:@"__enabled"] boolValue];
    [self loadCurrentGeoPush];
    
    self.locationManager = [[LocationHelper sharedInstance] locationManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableMonitoring) name:kLocationManagerStatusAuthorized object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)handleLocalPush:(UILocalNotification *)push {
    [GANHelper analyzeEvent:@"geo_push_opened" category:@"Geo_push_screen"];
    [[DBAPIClient sharedClient] POST:@"geo_push/add"
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 [GANHelper analyzeEvent:@"geo_push_add_success" category:@"Geo_push_screen"];
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 [GANHelper analyzeEvent:@"geo_push_add_failure" category:@"Geo_push_screen"];
                             }];
}

- (CLCircularRegion *)regionPointFromData:(NSDictionary *)pointInfo {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([pointInfo[@"lat"] doubleValue], [pointInfo[@"lon"] doubleValue]);
    CLLocationDistance radius = [pointInfo[@"radius"] doubleValue];
    NSString *identifier = [NSString stringWithFormat:@"%ld", [pointInfo[@"id"] integerValue]];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:identifier];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    return region;
}

- (void)loadCurrentGeoPush {
    self.geoPush = [NSKeyedUnarchiver unarchiveObjectWithData:[DBGeoPushManager valueForKey:@"__geoPush"]];
}

- (void)saveCurrentGeoPush {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.geoPush];
    [DBGeoPushManager setValue:data forKey:@"__geoPush"];
}

- (void)enableMonitoring {
    NSSet *regions = [self.locationManager monitoredRegions];
    for (CLRegion *region in regions) {
        if ([region isKindOfClass:[CLCircularRegion class]]) {
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
    
    if ([self.geoPush pushIsAvailable]) {
        for (NSDictionary *point in [self.geoPush points]) {
            CLCircularRegion *region = [self regionPointFromData:point];
            [self.locationManager startMonitoringForRegion:region];
        }
    }
}

#pragma mark – LocationHelperProtocol
- (void)didEnter:(CLRegion *)region {
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        if ([self.geoPush pushIsAvailable]) {
            NSInteger numberOfDays = [self.geoPush numberOfDaysAfterLastOrder];
            [GANHelper analyzeEvent:@"geo_push_may_be" label:[NSString stringWithFormat:@"%ld", numberOfDays] category:@"Geo_push_screen"];
            
            [self.geoPush pushLocalNotification];
        }
    }
}

#pragma mark - DBModuleManagerProtocol
- (void)enableModule:(BOOL)enabled withDict:(NSDictionary *)moduleDict {
    self.enabled = enabled;
    [DBGeoPushManager setValue:@(enabled) forKey:@"__enabled"];
    
    if (enabled) {
        self.geoPush = [[DBGeoPush alloc] initWithResponseDict:moduleDict[@"info"]];
        [self saveCurrentGeoPush];
        
        if ([[LocationHelper sharedInstance] isAuthorized]) {
            [self enableMonitoring];
        } else {
            [[LocationHelper sharedInstance] requestPermission];
        }
    }
}

#pragma mark - DBDataManager
+ (NSString *)db_managerStorageKey {
    return @"kDBDefaultsDBGeoPushManager";
}

@end
