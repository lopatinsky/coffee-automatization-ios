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

@interface DBMonthSubscriptionManager : DBPrimaryManager

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *subscriptionScreenTitle;
@property (strong, nonatomic) NSString *subscriptionScreenText;

@property (nonatomic) NSInteger *balance;

- (void)buySubscription:(void(^)(BOOL success, NSString *errorMessage))callback;

@end
