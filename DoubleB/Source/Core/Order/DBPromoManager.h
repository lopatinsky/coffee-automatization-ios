//
//  PromoManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 11.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerProtocol.h"
#import "OrderPartManagerProtocol.h"

@class OrderItem;
@class DBMenuPosition;
@class DBPromoItem;



typedef NS_ENUM(NSInteger, DBPromoManagerChange) {
    DBPromoManagerChangeDiscount = 0,
    DBPromoManagerChangeWalletDiscount,
    DBPromoManagerChangeWalletBalance,
    DBPromoManagerChangeShippingPrice,
    DBPromoManagerChangeUpdatedPromoInfo,
};

@interface DBPromoManager : NSObject<ManagerProtocol, OrderPartManagerProtocol>
- (void)updateInfo;


@property (strong, nonatomic) NSArray *promotionList;

//=========== Check of Current Order ===========

/**
 * Shipping total, should be not there
 */
@property (nonatomic) double shippingPrice;

/**
 * Discount for order synchronized with server
 */
@property (nonatomic, readonly) double discount;

/**
 * Total discount for order (discount + bonuses(if active))
 */
@property (nonatomic, readonly) double totalDiscount;

/**
 * Mark of order validity synchronized with server
 */
@property (nonatomic, readonly) BOOL validOrder;

/**
 * Order errors & promos from server
 */
@property (strong, nonatomic, readonly) NSArray *errors;
@property (strong, nonatomic, readonly) NSArray *promos;

/**
 * Gift positions available for order
 */
@property (strong, nonatomic, readonly) NSArray *orderGifts;

- (BOOL)checkCurrentOrder:(void(^)(BOOL success))callback;

- (DBPromoItem *)promosForOrderItem:(OrderItem *)item;

//=========== Check of Current Order ===========



//=========== Bonus Positions promo ===========
/**
 * Availability of bonus positions selection
 */
@property (nonatomic, readonly) BOOL bonusPositionsAvailable;

/**
 * Points available for selection of bonus positions
 */
@property (nonatomic, readonly) double bonusPointsBalance;

/**
 * Items which user can add to order using giftPoints
 */
@property (strong, nonatomic, readonly) NSArray *positionsAvailableAsBonuses;

/**
 * Text description for this promo
 */
@property(strong, nonatomic, readonly) NSString *bonusPositionsTextDescription;

//=========== Bonus Positions promo ===========



//=========== Personal Wallet promo ===========
/**
 * Define if personal wallet enabled
 */
@property(nonatomic, readonly) BOOL walletEnabled;

/**
 * Bonuses available for order payment
 */
@property (nonatomic) double walletDiscount;

/**
 * Define if user use bonuses for order payment
 */
@property (nonatomic) BOOL walletActiveForOrder;

/**
 * Currently accumulated personal wallet balance
 */
@property(nonatomic, readonly) double walletBalance;

/**
 * Text description for this promo
 */
@property(strong, nonatomic, readonly) NSString *walletTextDescription;

- (void)updatePersonalWalletBalance:(void(^)(double balance))callback;

//=========== Personal Wallet promo ===========

@end


typedef NS_ENUM(NSInteger, DBPromotionImageType) {
    DBPromotionImageTypePic = 0,
    DBPromotionImageTypeImage
};

/**
 * Class for holding info about each promotion
 */
@interface DBPromotion : NSObject
@property (strong, nonatomic) NSString *promotionName;
@property (strong, nonatomic) NSString *promotionDescription;

@property (nonatomic) DBPromotionImageType imageType;
@property (strong, nonatomic) NSString *imageUrl;

- (instancetype)initWithDict:(NSDictionary *)dict;
@end

/**
 * Class for manage all info about item promo
 */
@interface DBPromoItem : NSObject
@property (strong, nonatomic) OrderItem *orderItem;

@property (strong, nonatomic) NSArray *errors;
@property (strong, nonatomic) NSArray *promos;

@property (nonatomic) BOOL replaceToSubstituteAutomatic;
@property (strong, nonatomic) DBMenuPosition *substitute;

- (void)clear;
@end
