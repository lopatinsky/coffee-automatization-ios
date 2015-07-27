//
//  Coordinator.m
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import "OrderCoordinator.h"
#import "ItemsManager.h"
#import "BonusItemsManager.h"
#import "OrderManager.h"
#import "DeliverySettings.h"
#import "ShippingManager.h"
#import "DBPromoManager.h"
#import "DBClientInfo.h"

@implementation OrderCoordinator(EnumMap)

- (NSString * __nonnull)notificationNameByEnum:(CoordinatorNotification)en {
    return @[@"CoordinatorNotificationOrderTotalPrice", @"CoordinatorNotificationOrderDiscount"][en];
}

@end

@implementation OrderCoordinator

+ (instancetype)sharedInstance {
    static OrderCoordinator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OrderCoordinator alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    _itemsManager = [ItemsManager sharedInstance];
    _bonusItemsManager = [BonusItemsManager sharedInstance];
    _orderManager = [OrderManager sharedInstance];
    _deliverySettings = [DeliverySettings sharedInstance];
    _shippingManager = [ShippingManager sharedInstance];
    _promoManager = [DBPromoManager sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemsManagerNewTotalPriceNotificationHandler:)
                                                 name:kDBItemsManagerNewTotalPriceNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deliverySettingsNewTimeNotificationHandler:)
                                                 name:kDBDeliverySettingsNewSelectedTimeNotification object:nil];
    
    return self;
}


- (BOOL)validOrder{
    BOOL result = true;

    if(_deliverySettings.deliveryType.typeId == DeliveryTypeIdShipping){
        result = result && _shippingManager.validAddress;
    } else {
        result = result && _orderManager.venue;
    }
    result = result && !(_orderManager.paymentType == PaymentTypeNotSet);
    result = result && [[DBClientInfo sharedInstance] validClientName];
    result = result && [[DBClientInfo sharedInstance] validClientPhone];
    result = result && [[[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsNDASigned] boolValue];
    result = result && (_itemsManager.totalCount + _bonusItemsManager.totalCount) > 0;
    result = result && _promoManager.validOrder;

    return result;
}

#pragma mark - ItemsManager notifications

- (void)itemsManagerNewTotalPriceNotificationHandler:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[self notificationNameByEnum:CoordinatorNotificationOrderTotalPrice] object:nil]];
}

#pragma mark - DeliverySettings notifications

- (void)deliverySettingsNewTimeNotificationHandler:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[self notificationNameByEnum:CoordinatorNotificationNewSelectedTime] object:nil]];
}


#pragma mark - Notifications subscription

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(CoordinatorNotification)keyName selector:(__nonnull SEL)selector; {
    [[NSNotificationCenter defaultCenter] addObserver:object selector:selector name:[self notificationNameByEnum:keyName] object:nil];
}

- (void)removeObserver:(NSObject * __nonnull)observer forKeyPath:(CoordinatorNotification)keyName {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:[self notificationNameByEnum:keyName] object:nil];
}

- (void)removeObserver:(NSObject * __nonnull)observer{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

#pragma mark - Manager Protocol
- (void)flushCache {
    [_itemsManager flushCache];
    [_bonusItemsManager flushCache];
    [_orderManager flushCache];
    [_deliverySettings flushCache];
    [_shippingManager flushCache];
    [_promoManager flushCache];
}

- (void)flushStoredCache {
    [_itemsManager flushStoredCache];
    [_bonusItemsManager flushStoredCache];
    [_orderManager flushStoredCache];
    [_deliverySettings flushStoredCache];
    [_shippingManager flushStoredCache];
    [_promoManager flushStoredCache];
}

@end
