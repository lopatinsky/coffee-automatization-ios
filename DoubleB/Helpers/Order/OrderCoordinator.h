//
//  Coordinator.h
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import <Foundation/Foundation.h>

#import "ManagerProtocol.h"
#import "ItemsManager.h"
#import "BonusItemsManager.h"
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



@interface OrderCoordinator : NSObject <ManagerProtocol>

@property (nonnull, nonatomic, strong, readonly) ItemsManager *itemsManager;
@property (nonnull, nonatomic, strong, readonly) BonusItemsManager *bonusItemsManager;
@property (nonnull, nonatomic, strong, readonly) OrderManager *orderManager;
@property (nonnull, nonatomic, strong, readonly) DeliverySettings *deliverySettings;
@property (nonnull, nonatomic, strong, readonly) ShippingManager *shippingManager;
@property (nonnull, nonatomic, strong, readonly) DBPromoManager *promoManager;

- (BOOL)validOrder;

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(NSString * __nonnull)keyName selector:(__nonnull SEL)selector;
- (void)addObserver:(NSObject * __nonnull)object withKeyPaths:(NSArray * __nonnull)keyNames selector:(__nonnull SEL)selector;

- (void)removeObserver:(NSObject * __nonnull )observer forKeyPath:(NSString * __nonnull)keyName;
- (void)removeObserver:(NSObject * __nonnull )observer;

- (void)manager:(id<ManagerProtocol> __nonnull)manager haveChange:(NSInteger)changeType;

@end
