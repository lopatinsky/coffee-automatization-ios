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

+ (nonnull instancetype)sharedInstance;

- (BOOL)validOrder;

- (void)addObserver:(nonnull NSObject *)object withKeyPath:(nonnull NSString *)keyName selector:(nonnull SEL)selector;
- (void)addObserver:(nonnull NSObject *)object withKeyPaths:(nonnull NSArray *)keyNames selector:(nonnull SEL)selector;

- (void)removeObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyName;
- (void)removeObserver:(nonnull NSObject * )observer;

- (void)manager:(nonnull id<ManagerProtocol>)manager haveChange:(NSInteger)changeType;

@end
