//
//  DBMonthSubscriptionManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPrimaryManager.h"
#import "DBModuleManagerProtocol.h"

#import "DBSubscriptionVariant.h"
#import "DBCurrentSubscription.h"

extern NSString * __nonnull const kDBSubscriptionManagerCategoryIsAvailable;

@class DBMenuCategory;

@protocol DBSubscriptionManagerProtocol <NSObject>

- (void)currentSubscriptionStateChanged;

@end

@interface DBSubscriptionManager : DBPrimaryManager <DBModuleManagerProtocol>

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subscriptionScreenTitle;
@property (strong, nonatomic) NSString *subscriptionScreenText;
@property (strong, nonatomic) NSString *subscriptionMenuTitle;
@property (strong, nonatomic) NSString *subscriptionMenuText;
@property (strong, nonatomic) DBSubscriptionVariant *selectedVariant;
@property (strong, nonatomic) DBCurrentSubscription *currentSubscription;
@property (weak, nonatomic) id<DBSubscriptionManagerProtocol> delegate;
@property (nonatomic, strong) DBMenuCategory *subscriptionCategory;
@property (nonatomic) NSInteger *balance;

- (void)synchWithResponseInfo:(NSDictionary *)infoDict;
- (void)buySubscription:(DBSubscriptionVariant *)variant callback:(void(^)(BOOL success, NSString *errorMessage))callback;
- (void)checkSubscriptionVariants:(void(^)(NSArray *variants))success failure:(void(^)(NSString *errorMessage))failure;
- (void)subscriptionInfo:(void(^)(NSArray *info))success failure:(void(^)(NSString *errorMessage))failure;

- (nonnull NSArray<DBSubscriptionVariant *> *)subscriptionVariants;
- (nonnull NSDictionary *)cutSubscriptionCategory:(nonnull NSDictionary *)menu;
- (nonnull NSDictionary *)menuRequest;
- (nonnull DBMenuCategory *)subscriptionCategory;
- (BOOL)isAvailable;
- (BOOL)isEnabled;

- (BOOL)cupIsAvailableToPurchase;
- (NSInteger)numberOfAvailableCups;
- (void)incrementNumberOfCupsInOrder;
- (void)decrementNumberOfCupsInOrder;

@end
