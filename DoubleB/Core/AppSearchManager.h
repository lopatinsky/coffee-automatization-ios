//
//  AppSearchManager.h
//  
//
//  Created by Balaban Alexander on 08/09/15.
//
//

#import <Foundation/Foundation.h>

@protocol SearchableProtocol <NSObject>

- (nonnull NSString *)activityType;
- (nonnull NSString *)activityTitle;
- (nonnull NSDictionary *)activityUserInfo;
- (nonnull NSDate *)activityExpirationDate;
- (nonnull NSArray<NSString *> *)activityKeywords;
- (nonnull NSString *)activityDescription;

@end

@interface AppSearchManager : NSObject

+ (nullable instancetype)sharedManager;

- (void)createUserActivity:(nonnull id<SearchableProtocol>)searchable;
- (void)createPublicUserActivity:(nonnull id<SearchableProtocol>)searchable;

@end
