//
//  Coordinator.h
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import <Foundation/Foundation.h>

#import "DBBaseSettingsTableViewController.h"
#import "DBPrimaryManager.h"
#import "OrderPartManagerProtocol.h"

#import "ManagerProtocol.h"
#import "OrderItemsManager.h"
#import "OrderManager.h"
#import "DeliverySettings.h"
#import "ShippingManager.h"
#import "DBPromoManager.h"

extern NSString * __nonnull const CoordinatorNotificationOrderTotalPrice;
extern NSString * __nonnull const CoordinatorNotificationOrderDiscount;
extern NSString * __nonnull const CoordinatorNotificationOrderWalletDiscount;
extern NSString * __nonnull const CoordinatorNotificationOrderShippingPrice;

extern NSString * __nonnull const CoordinatorNotificationOrderItemsTotalCount;
extern NSString * __nonnull const CoordinatorNotificationBonusItemsTotalCount;
extern NSString * __nonnull const CoordinatorNotificationGiftItemsTotalCount;

extern NSString * __nonnull const CoordinatorNotificationNewDeliveryType;
extern NSString * __nonnull const CoordinatorNotificationNewSelectedTime;
extern NSString * __nonnull const CoordinatorNotificationNewPaymentType;
extern NSString * __nonnull const CoordinatorNotificationNewComment;
extern NSString * __nonnull const CoordinatorNotificationNewOddSum;
extern NSString * __nonnull const CoordinatorNotificationNewPersonsCount;
extern NSString * __nonnull const CoordinatorNotificationNDAAccept;
extern NSString * __nonnull const CoordinatorNotificationNewConfirmationType;

extern NSString * __nonnull const CoordinatorNotificationNewVenue;
extern NSString * __nonnull const CoordinatorNotificationNewShippingAddress;

extern NSString * __nonnull const CoordinatorNotificationAddressSuggestionsUpdated;
extern NSString * __nonnull const CoordinatorNotificationPromoUpdated;
extern NSString * __nonnull const CoordinatorNotificationPersonalWalletBalanceUpdated;


@interface OrderCoordinator : DBPrimaryManager <ManagerProtocol, OrderParentManagerProtocol, DBSettingsProtocol>

@property (nonnull, nonatomic, strong, readonly) OrderItemsManager *itemsManager;
@property (nonnull, nonatomic, strong, readonly) OrderBonusItemsManager *bonusItemsManager;
@property (nonnull, nonatomic, strong, readonly) OrderGiftItemsManager *orderGiftsManager;
@property (nonnull, nonatomic, strong, readonly) OrderManager *orderManager;
@property (nonnull, nonatomic, strong, readonly) DeliverySettings *deliverySettings;
@property (nonnull, nonatomic, strong, readonly) ShippingManager *shippingManager;
@property (nonnull, nonatomic, strong, readonly) DBPromoManager *promoManager;

/**
 * Check if all conditions of valid order are correct
 */
- (BOOL)validOrder;
- (nullable NSString *)orderErrorReason;

/**
 * If YES, OrderCoordinator will invoke updateOrderInfo independantly(when it necessary). By default automaticUpdate = NO
 */
@property (nonatomic) BOOL automaticUpdate;
/**
 * Synchronise order with server
 */
- (void)updateOrderInfo;

@end
