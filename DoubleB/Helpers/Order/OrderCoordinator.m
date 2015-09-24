//
//  Coordinator.m
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import "OrderCoordinator.h"
#import "DBClientInfo.h"
#import "DBCompanyInfo.h"
#import "NetworkManager.h"
#import "Venue.h"

NSString * __nonnull const CoordinatorNotificationOrderTotalPrice = @"CoordinatorNotificationOrderTotalPrice";
NSString * __nonnull const CoordinatorNotificationOrderDiscount = @"CoordinatorNotificationOrderDiscount";
NSString * __nonnull const CoordinatorNotificationOrderWalletDiscount = @"CoordinatorNotificationOrderWalletDiscount";
NSString * __nonnull const CoordinatorNotificationOrderShippingPrice = @"CoordinatorNotificationOrderShippingPrice";

NSString * __nonnull const CoordinatorNotificationNewSelectedTime = @"CoordinatorNotificationNewSelectedTime";

NSString * __nonnull const CoordinatorNotificationNewPaymentType = @"CoordinatorNotificationNewPaymentType";
NSString * __nonnull const CoordinatorNotificationNewVenue = @"CoordinatorNotificationNewVenue";

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
                                             selector:@selector(venuesUpdatedNotificationHandler:)
                                                 name:kDBConcurrentOperationFetchVenuesFinished object:nil];
    
    [[DBCompanyInfo sharedInstance] addObserver:self
                                    withKeyPath:DBCompanyInfoNotificationInfoUpdated
                                       selector:@selector(companyInfoUpdateNotificationHandler)];
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DBCompanyInfo sharedInstance] removeObserver:self];
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
            case OrderManagerChangeVenue:
                [self orderManagerDidChangeVenue];
                break;
        }
    }
    
    if([manager isKindOfClass:[DeliverySettings class]]){
        switch (changeType) {
            case DeliverySettingsChangeNewTime:
                [self deliverySettingsDidChangeTime];
                break;
        }
    }
    
    if([manager isKindOfClass:[ShippingManager class]]){
        switch (changeType) {
            case ShippingManagerChangeSuggestions:
                [self shippingManagerDidChangeSuggestions];
                break;
        }
    }
}

#pragma mark - External changes

- (void)newOrderCreatedNotificationHandler:(NSNotification *)notification{
    [_promoManager flushCache];
    [_orderManager flushCache];
    
    [_itemsManager flushCache];
    [_bonusItemsManager flushCache];
    [_orderGiftsManager flushCache];
}

- (void)companyInfoUpdateNotificationHandler{
    [_deliverySettings updateAfterDeliveryTypesUpdate];
}

- (void)venuesUpdatedNotificationHandler:(NSNotification *)notification {
    if (!self.orderManager.venue) {
        self.orderManager.venue = [[Venue storedVenues] firstObject];
    }
}

#pragma mark - ItemsManager changes

- (void)itemsManagerDidChangeTotalPrice{
    if(_itemsManager.totalCount == 0){
        [_promoManager flushCache];
    }
    
    [self notifyObserverOf:CoordinatorNotificationOrderTotalPrice];
}

#pragma mark - ShippingManager changes

- (void)shippingManagerDidChangeSuggestions{
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

- (void)orderManagerDidChangeVenue{
    [self notifyObserverOf:CoordinatorNotificationNewVenue];
}

#pragma mark - DeliverySettings changes

- (void)deliverySettingsDidChangeTime{
    [self notifyObserverOf:CoordinatorNotificationNewSelectedTime];
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
