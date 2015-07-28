//
//  Coordinator.m
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import "OrderCoordinator.h"
#import "DBClientInfo.h"

NSString * __nonnull const CoordinatorNotificationOrderTotalPrice = @"CoordinatorNotificationOrderTotalPrice";
NSString * __nonnull const CoordinatorNotificationOrderDiscount = @"CoordinatorNotificationOrderDiscount";
NSString * __nonnull const CoordinatorNotificationOrderWalletDiscount = @"CoordinatorNotificationOrderWalletDiscount";
NSString * __nonnull const CoordinatorNotificationOrderShippingPrice = @"CoordinatorNotificationOrderShippingPrice";

NSString * __nonnull const CoordinatorNotificationNewSelectedTime = @"CoordinatorNotificationNewSelectedTime";

NSString * __nonnull const CoordinatorNotificationAddressSuggestionsUpdated = @"CoordinatorNotificationAddressSuggestionsUpdated";
NSString * __nonnull const CoordinatorNotificationPromoUpdated = @"CoordinatorNotificationPromoUpdated";

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
                                             selector:@selector(newOrderCreatedNotificationHandler:)
                                                 name:kDBNewOrderCreatedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deliverySettingsNewTimeNotificationHandler:)
                                                 name:kDBDeliverySettingsNewSelectedTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shippingManagerNewSuggestionsNotificationHandler:)
                                                 name:kDBShippingManagerDidRecieveSuggestionsNotification object:nil];
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)validOrder {
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

- (void)manager:(id<ManagerProtocol> __nonnull)manager haveChange:(NSInteger)changeType{
    if([manager isKindOfClass:[ItemsManager class]]){
        switch (changeType) {
            case ItemsManagerChangeTotalPrice:
                [self itemsManagerDidChangeTotalPrice];
                break;
            case ItemsManagerChangeTotalCount:
                
                break;
        }
    }
    
    if([manager isKindOfClass:[DBPromoManager class]]){
        switch (changeType) {
            case DBPromoManagerChangeDiscount:
                [self promoManagerDidChangeDiscount];
                break;
            case DBPromoManagerChangeWalletDiscount:
                [self promoManagerDidChangeWalletDiscount];
                break;
            case DBPromoManagerChangeUpdatedPromoInfo:
                [self promoManagerDidUpdatePromoInfo];
                break;
            case DBPromoManagerChangeShippingPrice:
                [self promoManagerDidChangeShippingPrice];
                break;
        }
    }
}

- (void)newOrderCreatedNotificationHandler:(NSNotification *)notification{
    [_promoManager flushCache];
}

#pragma mark - ItemsManager changes

- (void)itemsManagerDidChangeTotalPrice{
    if(_itemsManager.totalCount == 0){
        [_promoManager flushCache];
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CoordinatorNotificationOrderTotalPrice object:nil]];
}

#pragma mark - DeliverySettings changes

- (void)deliverySettingsNewTimeNotificationHandler:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CoordinatorNotificationNewSelectedTime object:nil]];
}

#pragma mark - ShippingManager changes

- (void)shippingManagerNewSuggestionsNotificationHandler:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CoordinatorNotificationAddressSuggestionsUpdated object:nil]];
}

#pragma mark - PromoManager changes

- (void)promoManagerDidChangeDiscount{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CoordinatorNotificationOrderDiscount object:nil]];
}

- (void)promoManagerDidChangeWalletDiscount{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CoordinatorNotificationOrderWalletDiscount object:nil]];
}

- (void)promoManagerDidChangeShippingPrice{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CoordinatorNotificationOrderShippingPrice object:nil]];
}

- (void)promoManagerDidUpdatePromoInfo{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CoordinatorNotificationPromoUpdated object:nil]];
}


#pragma mark - Notifications subscription

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(NSString * __nonnull)keyName selector:(__nonnull SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:object selector:selector name:keyName object:nil];
}

- (void)addObserver:(NSObject * __nonnull)object withKeyPaths:(NSArray * __nonnull)keyNames selector:(__nonnull SEL)selector{
    for(NSString *keyName in keyNames){
        [self addObserver:object withKeyPath:keyName selector:selector];
    }
}

- (void)removeObserver:(NSObject * __nonnull )observer forKeyPath:(NSString * __nonnull)keyName {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:keyName object:nil];
}

- (void)removeObserver:(NSObject * __nonnull)observer {
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
