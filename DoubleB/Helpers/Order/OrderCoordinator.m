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

NSString * __nonnull const CoordinatorNotificationNewPaymentType = @"CoordinatorNotificationNewPaymentType";

NSString * __nonnull const CoordinatorNotificationAddressSuggestionsUpdated = @"CoordinatorNotificationAddressSuggestionsUpdated";
NSString * __nonnull const CoordinatorNotificationPromoUpdated = @"CoordinatorNotificationPromoUpdated";
NSString * __nonnull const CoordinatorNotificationPersonalWalletBalanceUpdated = @"CoordinatorNotificationPersonalWalletBalanceUpdated";

@implementation OrderCoordinator

- (instancetype)init {
    self = [super init];
    
    _itemsManager = [[OrderItemsManager alloc] initWithParentManager:self];
    _bonusItemsManager = [[OrderBonusItemsManager  alloc] initWithParentManager:self];
    _orderGiftsManager = [[OrderGiftItemsManager alloc] initWithParentManager:self];
    _orderManager = [[OrderManager  alloc] initWithParentManager:self];
    _deliverySettings = [[DeliverySettings  alloc] initWithParentManager:self];
    _shippingManager = [[ShippingManager  alloc] initWithParentManager:self];
    _promoManager = [[DBPromoManager  alloc] initWithParentManager:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newOrderCreatedNotificationHandler:)
                                                 name:kDBNewOrderCreatedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deliverySettingsNewTimeNotificationHandler:)
                                                 name:kDBDeliverySettingsNewSelectedTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shippingManagerNewSuggestionsNotificationHandler:)
                                                 name:kDBShippingManagerDidRecieveSuggestionsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(companyInfoUpdateNotificationHandler:)
                                                 name:kDBApplicationManagerInfoLoadSuccess object:nil];
    
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
    if([manager isKindOfClass:[OrderItemsManager class]]){
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
            case DBPromoManagerChangeWalletBalance:
                [self promoManagerDidChangeWalletBalance];
                break;
            case DBPromoManagerChangeUpdatedPromoInfo:
                [self promoManagerDidUpdatePromoInfo];
                break;
            case DBPromoManagerChangeShippingPrice:
                [self promoManagerDidChangeShippingPrice];
                break;
        }
    }
    
    if([manager isKindOfClass:[OrderManager class]]){
        switch (changeType) {
            case OrderManagerChangePaymentType:
                [self orderManagerDidChangePaymentType];
                break;
        }
    }
}

- (void)newOrderCreatedNotificationHandler:(NSNotification *)notification{
    [_promoManager flushCache];
}

#pragma mark - External changes

- (void)companyInfoUpdateNotificationHandler:(NSNotification *)notification{
    [_deliverySettings updateAfterDeliveryTypesUpdate];
}

#pragma mark - ItemsManager changes

- (void)itemsManagerDidChangeTotalPrice{
    if(_itemsManager.totalCount == 0){
        [_promoManager flushCache];
    }
    
    [self notifyObserverOf:CoordinatorNotificationOrderTotalPrice];
}

#pragma mark - DeliverySettings changes

- (void)deliverySettingsNewTimeNotificationHandler:(NSNotification *)notification{
    [self notifyObserverOf:CoordinatorNotificationNewSelectedTime];
}

#pragma mark - ShippingManager changes

- (void)shippingManagerNewSuggestionsNotificationHandler:(NSNotification *)notification{
    [self notifyObserverOf:CoordinatorNotificationAddressSuggestionsUpdated];
}

#pragma mark - PromoManager changes

- (void)promoManagerDidChangeDiscount{
    [self notifyObserverOf:CoordinatorNotificationOrderDiscount];
}

- (void)promoManagerDidChangeWalletDiscount{
    [self notifyObserverOf:CoordinatorNotificationOrderWalletDiscount];
}

- (void)promoManagerDidChangeWalletBalance{
    [self notifyObserverOf:CoordinatorNotificationPersonalWalletBalanceUpdated];
}

- (void)promoManagerDidChangeShippingPrice{
    [self notifyObserverOf:CoordinatorNotificationOrderShippingPrice];
}

- (void)promoManagerDidUpdatePromoInfo{
    [self notifyObserverOf:CoordinatorNotificationPromoUpdated];
}

#pragma mark - OrderManager changes

- (void)orderManagerDidChangePaymentType{
    [self notifyObserverOf:CoordinatorNotificationNewPaymentType];
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
