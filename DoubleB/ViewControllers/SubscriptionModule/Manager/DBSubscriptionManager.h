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

#import "SubscriptionInfoTableViewCell.h"

#import "DBSubscriptionVariant.h"
#import "DBCurrentSubscription.h"

extern NSString * __nonnull const kDBSubscriptionManagerCategoryIsAvailable;

@class DBMenuCategory;

@protocol DBSubscriptionManagerProtocol <NSObject>

- (void)currentSubscriptionStateChanged;

@end

@interface DBSubscriptionManager : DBPrimaryManager <DBModuleManagerProtocol>

@property (strong, nonatomic) NSString * __nonnull title;
@property (strong, nonatomic) NSString * __nonnull subscriptionScreenTitle;
@property (strong, nonatomic) NSString * __nonnull subscriptionScreenText;
@property (strong, nonatomic) NSString * __nonnull subscriptionMenuTitle;
@property (strong, nonatomic) NSString * __nonnull subscriptionMenuText;
@property (strong, nonatomic) DBSubscriptionVariant * __nonnull selectedVariant;
@property (strong, nonatomic) DBCurrentSubscription * __nonnull currentSubscription;
@property (weak, nonatomic) id<DBSubscriptionManagerProtocol> delegate;
@property (nonatomic, strong) DBMenuCategory * __nonnull subscriptionCategory;
@property (nonatomic) NSInteger balance;

+ (BOOL)categoryIsSubscription:(nonnull DBMenuCategory *)category;
+ (BOOL)isSubscriptionPosition:(nonnull NSIndexPath *)indexPath;

- (void)synchWithResponseInfo:( nonnull NSDictionary *)infoDict;
- (void)buySubscription:(nonnull DBSubscriptionVariant *)variant callback:(void(^ _Nonnull)(BOOL success, NSString * __nonnull errorMessage))callback;
- (void)checkSubscriptionVariants:(void(^ _Nonnull)(NSArray * __nonnull variants))success failure:(void(^ _Nonnull)(NSString * __nonnull errorMessage))failure;
- (void)subscriptionInfo:(void(^ _Nonnull)(NSArray * __nonnull info))success failure:(void(^ _Nonnull)(NSString * __nonnull errorMessage))failure;

- (nonnull NSArray<DBSubscriptionVariant *> *)subscriptionVariants;
- (nonnull NSDictionary *)cutSubscriptionCategory:(nonnull NSDictionary *)menu;
- (nonnull NSDictionary *)menuRequest;
- (nonnull DBMenuCategory *)subscriptionCategory;
- (BOOL)isAvailable;
- (BOOL)isEnabled;

- (BOOL)cupIsAvailableToPurchase;
- (NSInteger)numberOfAvailableCups;
- (void)incrementNumberOfCupsInOrder:(NSString * __nonnull)productId;
- (void)incrementNumberOfCupsInOrder;
- (void)decrementNumberOfCupsInOrder;

@end

@interface DBSubscriptionManager(TableViewInjection)

+ (NSInteger)numberOfRowsInSection:(NSInteger)section forCategory:(nonnull DBMenuCategory *)category;
+ (nullable SubscriptionInfoTableViewCell *)tryToDequeueSubscriptionCellForCategory:(nonnull DBMenuCategory *) category withIndexPath:(nonnull NSIndexPath *)indexPath andCell:(nonnull SubscriptionInfoTableViewCell *)cell;
+ (nonnull NSIndexPath *)correctedIndexPath:(nonnull NSIndexPath *)indexPath forCategory:(nonnull DBMenuCategory *)category;


@end