//
//  Coordinator.h
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import <Foundation/Foundation.h>

@class ItemsManager;
@class OrderManager;
@class GiftsManager;
@class TimeManager;
@class ShippingManager;
@class BonusManager;
@class PromoManager;

@interface OrderCoordinator : NSObject

@property (nonnull, nonatomic, strong) ItemsManager *itemsManager;
@property (nonnull, nonatomic, strong) OrderManager *orderManager;
@property (nonnull, nonatomic, strong) GiftsManager *giftsManager;
@property (nonnull, nonatomic, strong) TimeManager *timeManager;
@property (nonnull, nonatomic, strong) ShippingManager *shippingManager;
@property (nonnull, nonatomic, strong) BonusManager *bonusManager;
@property (nonnull, nonatomic, strong) PromoManager *promoManager;

@end
