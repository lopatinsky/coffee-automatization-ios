//
//  Coordinator.h
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import <Foundation/Foundation.h>

#import "ManagerProtocol.h"

#import "OrderManager.h"
#import "ItemsManager.h"
#import "BonusItemsManager.h"

@class ItemsManager;
@class GiftsManager;
@class TimeManager;
@class ShippingManager;
@class PromoManager;

typedef enum : NSUInteger {
    Test1, Test2
} CoordinatorEnum;

@interface OrderCoordinator : NSObject <ManagerProtocol>

@property (nonnull, nonatomic, strong) ItemsManager *itemsManager;
@property (nonnull, nonatomic, strong) OrderManager *orderManager;
@property (nonnull, nonatomic, strong) GiftsManager *giftsManager;
@property (nonnull, nonatomic, strong) TimeManager *timeManager;
@property (nonnull, nonatomic, strong) ShippingManager *shippingManager;
@property (nonnull, nonatomic, strong) BonusItemsManager *bonusItemsManager;
@property (nonnull, nonatomic, strong) PromoManager *promoManager;

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(CoordinatorEnum)keyName;
- (void)removeObserver:(NSObject * __nonnull )observer forKeyPath:(CoordinatorEnum)keyPath;

@end
