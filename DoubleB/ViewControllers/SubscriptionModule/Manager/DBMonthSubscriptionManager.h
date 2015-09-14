//
//  DBMonthSubscriptionManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPrimaryManager.h"

@class DBPaymentCard;

@interface DBMonthSubscriptionVariant : NSObject<NSCoding>

@property (strong, nonatomic) NSString *variantId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *variantDescription;
@property (nonatomic) NSInteger count;
@property (nonatomic) double price;
@property (nonatomic) NSInteger period;

- (instancetype)initWithResponseDict:(NSDictionary *)dict;

@end

@interface DBMonthSubscriptionManager : DBPrimaryManager

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *subscriptionScreenTitle;
@property (strong, nonatomic) NSString *subscriptionScreenText;

@property (strong, nonatomic) NSArray *subscriptionVariants;
@property (nonatomic) NSInteger *balance;
@property (strong, nonatomic) DBMenuPosition *positon;

- (void)synchWithResponseInfo:(NSDictionary *)infoDict;

- (void)buySubscription:(DBMonthSubscriptionVariant *)variant
               callback:(void(^)(BOOL success, NSString *errorMessage))callback;

- (void)checkSubscriptionVariants:(void(^)(NSArray *variants))success
                          failure:(void(^)(NSString *errorMessage))failure;

@end
