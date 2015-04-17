//
//  DBMastercardAdvert.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDBMastercardPromoUpdatedNotification;

@interface DBMastercardPromo : NSObject

@property(nonatomic, readonly) NSDate *promoEndDate;
@property(nonatomic, readonly) NSInteger promoMaxPointsCount;
@property(nonatomic, readonly) NSInteger promoCurrentPointsCount;
@property(nonatomic, readonly) NSInteger promoCurrentMugCount;
@property(nonatomic, readonly) BOOL hasPromoOrders;
@property(nonatomic, readonly) BOOL onlyForMastercard;
@property(nonatomic) NSDictionary *lastNews;

+ (instancetype)sharedInstance;

- (BOOL)promoIsAvailable;
- (BOOL)userIntoPromo;
- (void)synchronisePromoInfoForClient:(NSString *)clientId;

- (void)synchronisePromoInfoForClient:(NSString *)clientId
                  withCompletionBlock:(void (^)())block;

- (void)doneOrder;
- (void)doneOrderWithMugCount:(NSInteger)count;

@end
