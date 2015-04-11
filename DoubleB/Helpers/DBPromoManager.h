//
//  PromoManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 11.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@class Venue;

@class DBPromoManager;

@protocol DBPromoManagerUpdateInfoDelegate <NSObject>
@required
- (void)promoManager:(DBPromoManager *)manager didUpdateInfo:(NSArray *)itemsInfo promos:(NSArray *)promos;
- (void)promoManager:(DBPromoManager *)manager didUpdateInfo:(NSArray *)itemsInfo errors:(NSArray *)errors promos:(NSArray *)promos;
- (void)promoManager:(DBPromoManager *)mamager didFailUpdateInfoWithError:(NSError *)error;
@end

@protocol DBPromoManagerUpdateTotalDelegate <NSObject>
@required
- (void)promoManager:(DBPromoManager *)manager didUpdateInfoWithTotal:(double)totalSum;
@end

@interface DBPromoManager : NSObject

@property (weak, nonatomic) id<DBPromoManagerUpdateInfoDelegate> updateInfoDelegate;
@property (weak, nonatomic) id<DBPromoManagerUpdateTotalDelegate> updateTotalDelegate;
@property (nonatomic) BOOL validOrder;

+ (instancetype)sharedManager;

- (void)updateInfo;

@end
