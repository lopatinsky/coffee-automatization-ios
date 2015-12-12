//
//  AppIndexingManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 14/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreSpotlight/CoreSpotlight.h>

@protocol UserActivityIndexing <NSObject>

- (nonnull NSString *)activityTitle;
- (nonnull NSDictionary *)activityUserInfo;
- (nonnull CSSearchableItemAttributeSet *)activityAttributes;
- (BOOL)activityIsAvailable;
- (void)activityDidAppear;

@end

@protocol SpotlightIndexing <NSObject>

- (nonnull NSString *)spotlightUniqueIdentifier;
- (nonnull NSString *)spotlightDomainIdentifier;
- (nonnull CSSearchableItemAttributeSet *)spotlightAttributes;

@end

@interface AppIndexingManager : NSObject

+ (nonnull instancetype)sharedManager;
- (BOOL)isAvailable;
- (void)continueUserActivity:(nonnull NSUserActivity *)activity;
- (void)postActivity:(nonnull id<UserActivityIndexing>)obj withParams:(nonnull NSDictionary *)params;
- (void)indexObject:(nonnull id<SpotlightIndexing>)obj withParams:(nonnull NSDictionary *)params;
- (void)deleteIndexiesWithIdentifiers:(nonnull NSString *)identifier;
- (void)deleteIndexiesWithDomainIdentifier:(nonnull NSString *)domainIdentifier;
- (void)deleteAllIndexies;

@end