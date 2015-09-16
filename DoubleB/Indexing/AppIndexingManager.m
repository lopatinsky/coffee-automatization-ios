//
//  AppIndexingManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 14/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "AppIndexingManager.h"
#import "UIDevice+OSVersion.h"
#import "NSDate+Difference.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "PostUserActivity.h"
#import "IndexObject.h"

@interface AppIndexingManager()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *activities;

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
    _operationQueue = [NSOperationQueue new];
    _operationQueue.maxConcurrentOperationCount = 1;
    _operationQueue.name = @"AppIndexingManagerQueue";
    return self;
}

- (BOOL)isAvailable {
    return [UIDevice systemVersionGreaterThanOrEquals:@"9.0"];
}

#pragma mark - Continue Activity

- (void)continueUserActivity:(NSUserActivity *)activity {
    if ([UIDevice systemVersionLessThan:@"9.0"]) { return; }
    
    if (activity.activityType == CSSearchableItemActionType) {
        NSString *uniqueIdentifier = [[activity userInfo] objectForKey:CSSearchableItemActivityIdentifier];
        // handle spotlight API
    } else {
        // handle nsuseractivity
        if ([activity.activityType isEqualToString:@""]) {
            
        }
    }
}

#pragma mark - NSUserActivity

- (void)postActivity:(id<UserActivityIndexing>)obj withParams:(NSDictionary *)params {
    if ([UIDevice systemVersionLessThan:@"9.0"]) { return; }
    [self.operationQueue addOperation:[[PostUserActivity alloc] initWithObject:obj andParams:params]];
}

#pragma mark - Spotlight API

- (void)indexObject:(id<SpotlightIndexing>)obj withParams:(NSDictionary *)params {
    if ([UIDevice systemVersionLessThan:@"9.0"]) { return; }
    [self.operationQueue addOperation:[[IndexObject alloc] initWithObject:obj andParams:params]];
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
