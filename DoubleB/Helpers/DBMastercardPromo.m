//
//  DBMastercardAdvert.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMastercardPromo.h"
#import "DBAPIClient.h"
#import "IHSecureStore.h"
#import "IHPaymentManager.h"
#import "Order.h"
#import "Venue.h"
#import "LocationHelper.h"
#import "Compatibility.h"

NSString *const kDBMastercardPromoUpdatedNotification = @"kDBMastercardPromoUpdatedNotification";

NSString *const kDBDefaultsMastercardPromoInfo = @"kDBDefaultsMastercardPromoInfo";

@interface DBMastercardPromo ()

@property(nonatomic) BOOL isPromoAvailable;
@property(strong, nonatomic) NSMutableSet *expiredNews;

@end

@implementation DBMastercardPromo

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBMastercardPromo *instance = nil;
    dispatch_once(&once, ^{
        instance = [DBMastercardPromo new];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    
    if(self){
        NSDictionary *masterPromoInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsMastercardPromoInfo];
        if(masterPromoInfo){
            _isPromoAvailable = [masterPromoInfo[@"isPromoAvailable"] boolValue];
            _promoEndDate = masterPromoInfo[@"promoEndDate"] ?: [NSDate date];
            _onlyForMastercard = [masterPromoInfo[@"isPromoOnlyForMastercard"] boolValue];
            _hasPromoOrders = [masterPromoInfo[@"hasPromoOrders"] boolValue];
            _promoMaxPointsCount = [masterPromoInfo[@"maxPointsCount"] integerValue];
            _promoCurrentPointsCount = [masterPromoInfo[@"currentPointsCount"] integerValue];
            _promoCurrentMugCount = [masterPromoInfo[@"currentMugCount"] integerValue];
            _expiredNews = masterPromoInfo[@"expiredNews"] ? [[NSMutableSet alloc] initWithArray:masterPromoInfo[@"expiredNews"]] : [[NSMutableSet alloc] init];
        } else {
            _expiredNews = [[NSMutableSet alloc] init];
        }
    }
    
    return self;
}

- (void)synchronisePromoInfoForClient:(NSString *)clientId{
//    [self synchronisePromoInfoForClient:clientId withCompletionBlock:nil];
}

- (void)synchronisePromoInfoForClient:(NSString *)clientId
                  withCompletionBlock:(void (^)())block{
    if(clientId){
        [[DBAPIClient sharedClient] GET:@"promo_info"
                             parameters:@{@"client_id": @(clientId.intValue)}
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    // Mastercard promo
                                    _isPromoAvailable = [responseObject[@"promo_enabled"] boolValue];
                                    _promoEndDate = [NSDate dateWithTimeIntervalSince1970:[responseObject[@"promo_end_date"] intValue]];
                                    _onlyForMastercard = [responseObject[@"promo_mastercard_only"] boolValue];
                                    _hasPromoOrders = [responseObject[@"has_mastercard_orders"] boolValue];
                                    
                                    _lastNews = [responseObject[@"news"] firstObject];
                                    
                                    if(_lastNews[@"id"]){
                                        if(![_expiredNews containsObject:_lastNews[@"id"]]){
                                            [_expiredNews addObject:_lastNews[@"id"]];
                                        } else {
                                            _lastNews = nil;
                                        }
                                    }
                                    
                                    NSNumber *pointsPerCup = responseObject[@"points_per_cup"];
                                    NSNumber *bonusPoints = responseObject[@"bonus_points"];
                                    
                                    if(pointsPerCup && [pointsPerCup intValue] > 0 && bonusPoints){
                                        _promoMaxPointsCount = [pointsPerCup intValue];
                                        _promoCurrentMugCount = [bonusPoints intValue] / _promoMaxPointsCount;
                                        _promoCurrentPointsCount = [bonusPoints intValue] % _promoMaxPointsCount;
                                    } else {
                                        _isPromoAvailable = NO;
                                    }
                                    
                                    [self synchronise];
                                    
                                    if(block){
                                        block();
                                    } else {
                                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBMastercardPromoUpdatedNotification object:nil]];
                                    }
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
                                }];
    }
}

- (BOOL)promoIsAvailable{
    NSArray *availablePaymentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsAvailablePaymentTypes];
    return self.isPromoAvailable && [availablePaymentTypes containsObject:@(PaymentTypeCard)];
}

- (BOOL)userIntoPromo{
    NSArray *cards = [[IHSecureStore sharedInstance] cards];
    BOOL hasMastercard = NO;
    for(NSDictionary *card in cards){
        if([[card[@"cardPan"] db_cardIssuer] isEqualToString:kDBCardTypeMasterCard]){
            hasMastercard = YES;
            break;
        }
    }
    
    return (_isPromoAvailable && ((_onlyForMastercard && hasMastercard) || !_onlyForMastercard));
}

- (void)doneOrder{
    if(_isPromoAvailable && [self userIntoPromo]){
        _hasPromoOrders = YES;
        [self synchronise];
        [self synchronisePromoInfoForClient:[IHSecureStore sharedInstance].clientId];
    }
}

- (void)doneOrderWithMugCount:(NSInteger)count{
    _hasPromoOrders = YES;
    _promoCurrentMugCount -= count;
    [self synchronise];
    [self synchronisePromoInfoForClient:[IHSecureStore sharedInstance].clientId];
}

- (void)synchronise{
    // Save mastercard promo info
    NSDictionary *promoInfo = @{@"isPromoAvailable": @(_isPromoAvailable),
                                @"promoEndDate": _promoEndDate,
                                @"isPromoOnlyForMastercard": @(_onlyForMastercard),
                                @"hasPromoOrders": @(_hasPromoOrders),
                                @"maxPointsCount": @(_promoMaxPointsCount),
                                @"currentPointsCount": @(_promoCurrentPointsCount),
                                @"currentMugCount": @(_promoCurrentMugCount),
                                @"expiredNews": _expiredNews ? [_expiredNews allObjects] : [NSArray array]};
    [[NSUserDefaults standardUserDefaults] setObject:promoInfo forKey:kDBDefaultsMastercardPromoInfo];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
