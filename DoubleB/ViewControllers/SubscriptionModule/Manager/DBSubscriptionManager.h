//
//  DBMonthSubscriptionManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPrimaryManager.h"

#import "DBSubscriptionVariant.h"

@interface DBSubscriptionManager : DBPrimaryManager

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subscriptionScreenTitle;
@property (strong, nonatomic) NSString *subscriptionScreenText;
@property (strong, nonatomic) DBMenuPosition *positon;
@property (nonatomic) NSInteger *balance;

- (void)synchWithResponseInfo:(NSDictionary *)infoDict;
- (void)buySubscription:(DBSubscriptionVariant *)variant callback:(void(^)(BOOL success, NSString *errorMessage))callback;
- (void)checkSubscriptionVariants:(void(^)(NSArray *variants))success failure:(void(^)(NSString *errorMessage))failure;

- (NSArray<DBSubscriptionVariant *> *)subscriptionVariants;

@end
