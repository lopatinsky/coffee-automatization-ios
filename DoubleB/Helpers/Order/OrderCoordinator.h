//
//  Coordinator.h
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import <Foundation/Foundation.h>

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

extern NSString * __nonnull const CoordinatorNotificationNewSelectedTime;

extern NSString * __nonnull const CoordinatorNotificationAddressSuggestionsUpdated;
extern NSString * __nonnull const CoordinatorNotificationPromoUpdated;
extern NSString * __nonnull const CoordinatorNotificationPersonalWalletBalanceUpdated;



@interface OrderCoordinator : NSObject <ManagerProtocol>

@property (nonnull, nonatomic, strong, readonly) OrderItemsManager *itemsManager;
@property (nonnull, nonatomic, strong, readonly) OrderBonusItemsManager *bonusItemsManager;
@property (nonnull, nonatomic, strong, readonly) OrderGiftItemsManager *orderGiftsManager;
@property (nonnull, nonatomic, strong, readonly) OrderManager *orderManager;
@property (nonnull, nonatomic, strong, readonly) DeliverySettings *deliverySettings;
@property (nonnull, nonatomic, strong, readonly) ShippingManager *shippingManager;
@property (nonnull, nonatomic, strong, readonly) DBPromoManager *promoManager;

+ (instancetype)sharedInstance;

- (BOOL)validOrder;

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(NSString * __nonnull)keyName selector:(__nonnull SEL)selector;
- (void)addObserver:(NSObject * __nonnull)object withKeyPaths:(NSArray * __nonnull)keyNames selector:(__nonnull SEL)selector;

- (void)removeObserver:(NSObject * __nonnull )observer forKeyPath:(NSString * __nonnull)keyName;
- (void)removeObserver:(NSObject * __nonnull )observer;

- (void)manager:(id<ManagerProtocol> __nonnull)manager haveChange:(NSInteger)changeType;

@end
