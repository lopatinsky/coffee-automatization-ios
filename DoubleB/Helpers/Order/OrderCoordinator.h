//
//  Coordinator.h
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import <Foundation/Foundation.h>

#import "ManagerProtocol.h"

@class ItemsManager;
@class BonusItemsManager;
@class OrderManager;
@class DeliverySettings;
@class ShippingManager;
@class DBPromoManager;

typedef NS_ENUM(NSUInteger, CoordinatorNotification) {
    CoordinatorNotificationOrderTotalPrice = 0,
    CoordinatorNotificationOrderDiscount,
    CoordinatorNotificationNewSelectedTime,
    CoordinatorNotificationNewAddressSuggestions
};

@interface OrderCoordinator : NSObject <ManagerProtocol>

@property (nonnull, nonatomic, strong, readonly) ItemsManager *itemsManager;
@property (nonnull, nonatomic, strong, readonly) BonusItemsManager *bonusItemsManager;
@property (nonnull, nonatomic, strong, readonly) OrderManager *orderManager;
@property (nonnull, nonatomic, strong, readonly) DeliverySettings *deliverySettings;
@property (nonnull, nonatomic, strong, readonly) ShippingManager *shippingManager;
@property (nonnull, nonatomic, strong, readonly) DBPromoManager *promoManager;

- (BOOL)validOrder;

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(CoordinatorNotification)keyName selector:(__nonnull SEL)selector;
- (void)removeObserver:(NSObject * __nonnull)observer forKeyPath:(CoordinatorNotification)keyName;
- (void)removeObserver:(NSObject * __nonnull)observer;

@end
