//
//  AppIndexingManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 14/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//


#import "AppIndexingManager.h"
#import "ApplicationManager.h"
#import "UIDevice+OSVersion.h"
#import "NSDate+Difference.h"
#import "NSOperation+UniqueOperation.h"

#import "UserActivityOperation.h"
#import "SpotlightIndexOperation.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface AppIndexingManager()

@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, strong) NSOperationQueue *activitiesQueue;

@end

@implementation AppIndexingManager

+ (instancetype)sharedManager {
    static AppIndexingManager *instance = nil;
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        instance = [[AppIndexingManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    _activities = [NSMutableArray new];
    _activitiesQueue = [[NSOperationQueue alloc] init];
    [_activitiesQueue setMaxConcurrentOperationCount:1];
    return self;
}

- (BOOL)isAvailable {
    return [UIDevice systemVersionGreaterOrEqualsThan:@"9.0"];
}

#pragma mark - Continue Activity

- (void)continueUserActivity:(NSUserActivity *)activity {
    if ([UIDevice systemVersionLessThan:@"9.0"]) { return; }
    if (activity.activityType == CSSearchableItemActionType) {
//        NSString *uniqueIdentifier = [[activity userInfo] objectForKey:CSSearchableItemActivityIdentifier];
        // handle spotlight API
    } else {
        if ([activity.activityType isEqualToString:@"order"]) {
            NSString *orderId = [activity.userInfo objectForKey:@"order_id"];
            [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenHistoryOrder object:orderId animated:YES];
        } else if ([activity.activityType isEqualToString:@"position"]) {
            NSLog(@"%@", activity.userInfo);
        } else if ([activity.activityType isEqualToString:@"venue"]) {
            NSString *venueId = [activity.userInfo objectForKey:@"venue_id"];
            [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenVenue object:venueId animated:YES];
        }
    }
}

#pragma mark - NSUserActivity

- (void)postActivity:(id<UserActivityIndexing>)obj withParams:(NSDictionary *)params {
    if ([UIDevice systemVersionLessThan:@"9.0"]) { return; }
    
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:[params objectForKey:@"type"] ?: @"default"];
    
    userActivity.title = [obj activityTitle];
    userActivity.userInfo = [obj activityUserInfo];
    userActivity.contentAttributeSet = [obj activityAttributes];
    userActivity.expirationDate = [params objectForKey:@"expirationDate"] ?: [NSDate distantFuture];
    
    userActivity.eligibleForSearch = [params objectForKey:@"eligibleForSearch"] ?: @(YES);
    userActivity.eligibleForHandoff = [params objectForKey:@"eligibleForHandoff"] ?: @(NO);
    userActivity.eligibleForPublicIndexing = [params objectForKey:@"eligibleForPublicIndexing"] ?: @(NO);
    
    [self.activities addObject:userActivity];
    [self.activitiesQueue addConcurrentPendingOperation:[[UserActivityOperation alloc] initWithUserInfo:@{@"activity": userActivity, @"obj": obj}]];
}

#pragma mark - Spotlight API

- (void)indexObject:(id<SpotlightIndexing>)obj withParams:(NSDictionary *)params {
    if ([UIDevice systemVersionLessThan:@"9.0"]) { return; }
    
    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[obj spotlightUniqueIdentifier] domainIdentifier:[obj spotlightDomainIdentifier]
                                                                   attributeSet:[obj spotlightAttributes]];
    item.expirationDate = [params objectForKey:@"expirationDate"] ?: [NSDate distantFuture];
    [self.activitiesQueue addOperation:[[SpotlightIndexOperation alloc] initWithUserInfo:@{@"spotlight": item}]];
}

- (void)deleteIndexiesWithIdentifiers:(NSString *)identifier {
    if ([UIDevice systemVersionLessThan:@"9.0"]) { return; }
    
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:@[identifier] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s", __PRETTY_FUNCTION__);
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void)deleteIndexiesWithDomainIdentifier:(NSString *)domainIdentifier {
    if ([UIDevice systemVersionLessThan:@"9.0"]) { return; }
    
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithDomainIdentifiers:@[domainIdentifier] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s", __PRETTY_FUNCTION__);
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void)deleteAllIndexies {
    if ([UIDevice systemVersionLessThan:@"9.0"]) { return; }
    
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s", __PRETTY_FUNCTION__);
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

@end
