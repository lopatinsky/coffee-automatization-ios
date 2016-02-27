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
#import "DBPersonalWalletView.h"
#import "NetworkManager.h"
#import "Venue.h"

NSString * __nonnull const CoordinatorNotificationOrderTotalPrice = @"CoordinatorNotificationOrderTotalPrice";
NSString * __nonnull const CoordinatorNotificationOrderDiscount = @"CoordinatorNotificationOrderDiscount";
NSString * __nonnull const CoordinatorNotificationOrderWalletDiscount = @"CoordinatorNotificationOrderWalletDiscount";
NSString * __nonnull const CoordinatorNotificationOrderShippingPrice = @"CoordinatorNotificationOrderShippingPrice";

NSString * __nonnull const CoordinatorNotificationOrderItemsTotalCount = @"CoordinatorNotificationOrderItemsTotalCount";
NSString * __nonnull const CoordinatorNotificationBonusItemsTotalCount = @"CoordinatorNotificationBonusItemsTotalCount";
NSString * __nonnull const CoordinatorNotificationGiftItemsTotalCount = @"CoordinatorNotificationGiftItemsTotalCount";

NSString * __nonnull const CoordinatorNotificationNewDeliveryType = @"CoordinatorNotificationNewDeliveryType";
NSString * __nonnull const CoordinatorNotificationNewSelectedTime = @"CoordinatorNotificationNewSelectedTime";
NSString * __nonnull const CoordinatorNotificationNewPaymentType = @"CoordinatorNotificationNewPaymentType";
NSString * __nonnull const CoordinatorNotificationNewComment = @"CoordinatorNotificationNewComment";
NSString * __nonnull const CoordinatorNotificationNewOddSum = @"CoordinatorNotificationNewOddSum";
NSString * __nonnull const CoordinatorNotificationNewPersonsCount = @"CoordinatorNotificationNewPersonsCount";
NSString * __nonnull const CoordinatorNotificationNDAAccept = @"CoordinatorNotificationNDAAccept";
NSString * __nonnull const CoordinatorNotificationNewConfirmationType = @"CoordinatorNotificationNewConfirmationType";

NSString * __nonnull const CoordinatorNotificationNewVenue = @"CoordinatorNotificationNewVenue";
NSString * __nonnull const CoordinatorNotificationNewShippingAddress = @"CoordinatorNotificationNewShippingAddress";

NSString * __nonnull const CoordinatorNotificationAddressSuggestionsUpdated = @"CoordinatorNotificationAddressSuggestionsUpdated";
NSString * __nonnull const CoordinatorNotificationPromoUpdated = @"CoordinatorNotificationPromoUpdated";
NSString * __nonnull const CoordinatorNotificationPersonalWalletBalanceUpdated = @"CoordinatorNotificationPersonalWalletBalanceUpdated";

@implementation OrderCoordinator

- (instancetype)init {
    self = [super init];
    
    self.automaticUpdate = NO;
    
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
    result = result && [DBClientInfo sharedInstance].clientName.valid;
    result = result && [DBClientInfo sharedInstance].clientPhone.valid;
    result = result && _orderManager.ndaAccepted;
    result = result && (_itemsManager.totalCount + _bonusItemsManager.totalCount) > 0;
    result = result && _promoManager.validOrder;

    return result;
}

- (NSString *)orderErrorReason {
    NSString *reason = nil;
    
    if(!reason && (_itemsManager.totalCount + _bonusItemsManager.totalCount) == 0) {
        reason = NSLocalizedString(@"Невозможно разместить пустой заказ", nil);
    }
    
    if (!reason && ![DBClientInfo sharedInstance].clientName.valid) {
        reason = NSLocalizedString(@"Пожалуйста, укажите ваше имя", nil);
    }
    
    if (!reason && ![DBClientInfo sharedInstance].clientPhone.valid) {
        reason = NSLocalizedString(@"Пожалуйста, укажите ваш номер телефона", nil);
    }
    
    if (!reason && !_promoManager.validOrder) {
        reason = _promoManager.errors.firstObject;
    }
    
    if(_deliverySettings.deliveryType.typeId == DeliveryTypeIdShipping){
        if (!reason && !_shippingManager.validAddress)
            reason = NSLocalizedString(@"Пожалуйста, введите адрес доставки", nil);
    } else {
        if (!reason && !_orderManager.venue)
            reason = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Пожалуйста, выберите", nil), [DBTextResourcesHelper db_venueTitleString:4]];
    }
    
    if (!reason && _orderManager.paymentType == PaymentTypeNotSet) {
        reason = NSLocalizedString(@"Выберите тип оплаты", nil);
    }
    
    if (!reason && !_orderManager.ndaAccepted) {
        reason = NSLocalizedString(@"Необходимо ознакомиться с правилами оплаты", nil);
    }
    
    if (!reason && ![self validOrder]) {
        reason = NSLocalizedString(@"Не удалось обновить сумму заказа, пожалуйста проверьте ваше интернет-соединение", nil);
    }
    
    return reason;
}

- (void)automaticUpdateOrderInfo {
    if (_automaticUpdate) {
        [self updateOrderInfo];
    }
}

- (void)updateOrderInfo {
    [[NetworkManager sharedManager] forceAddOperation:NetworkOperationCheckOrder];
}

- (void)manager:(id<OrderPartManagerProtocol>)manager haveChange:(NSInteger)changeType{
    if([manager isKindOfClass:[OrderItemsManager class]]){
        switch (changeType) {
            case ItemsManagerChangeTotalPrice:
                [self orderItemsManagerDidChangeTotalPrice];
                break;
            case ItemsManagerChangeTotalCount:
                [self orderItemsManagerDidChangeTotalCount];
                break;
        }
    }
    
    if([manager isKindOfClass:[OrderBonusItemsManager class]]){
        switch (changeType) {
            case ItemsManagerChangeTotalCount:
                [self bonusItemsManagerDidChangeTotalCount];
                break;
        }
    }
    
    if([manager isKindOfClass:[OrderGiftItemsManager class]]){
        switch (changeType) {
            case ItemsManagerChangeTotalCount:
                [self giftItemsManagerDidChangeTotalCount];
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
            case OrderManagerChangeComment:
                [self orderManagerDidChangeComment];
                break;
            case OrderManagerChangeOddSum:
                [self orderManagerDidChangeOddSum];
                break;
            case OrderManagerChangePersonsCount:
                [self orderManagerDidChangePersonsCount];
                break;
            case OrderManagerChangeNDAAccept:
                [self orderManagerDidChangeNDAAccept];
                break;
            case OrderManagerChangeConfirmationType:
                [self orderManagerDidChangeConfirmationType];
                break;
        }
    }
    
    if([manager isKindOfClass:[DeliverySettings class]]){
        switch (changeType) {
            case DeliverySettingsChangeNewTime:
                [self deliverySettingsDidChangeTime];
                break;
            case DeliverySettingsChangeNewDeliveryType:
                [self deliverySettingsDidChangeDeliveryType];
                break;
        }
    }
    
    if([manager isKindOfClass:[ShippingManager class]]){
        switch (changeType) {
            case ShippingManagerChangeSuggestions:
                [self shippingManagerDidChangeSuggestions];
                break;
            case ShippingManagerChangeAddress:
                [self shippingManagerDidChangeAddress];
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
    
    if(_shippingManager.selectedAddress.city.length == 0)
        [_shippingManager setCity:[_shippingManager.arrayOfCities firstObject]];
}

- (void)venuesUpdatedNotificationHandler:(NSNotification *)notification {
    if (!self.orderManager.venue) {
        self.orderManager.venue = [[Venue storedVenues] firstObject];
    }
}

#pragma mark - OrderItemsManager changes

- (void)orderItemsManagerDidChangeTotalPrice{
    [self notifyObserverOf:CoordinatorNotificationOrderTotalPrice];
}

- (void)orderItemsManagerDidChangeTotalCount{
    if(_itemsManager.totalCount == 0){
        [_promoManager flushCache];
    }
    
    [self automaticUpdateOrderInfo];
    
    [self notifyObserverOf:CoordinatorNotificationOrderItemsTotalCount];
}

#pragma mark - BonusItemsManager changes
- (void)bonusItemsManagerDidChangeTotalCount{
    [self automaticUpdateOrderInfo];
    [self notifyObserverOf:CoordinatorNotificationBonusItemsTotalCount];
}

#pragma mark - GiftItemsManager changes
- (void)giftItemsManagerDidChangeTotalCount{
    [self notifyObserverOf:CoordinatorNotificationGiftItemsTotalCount];
}

#pragma mark - ShippingManager changes

- (void)shippingManagerDidChangeSuggestions{
    [self notifyObserverOf:CoordinatorNotificationAddressSuggestionsUpdated];
}

- (void)shippingManagerDidChangeAddress{
    [self automaticUpdateOrderInfo];
    
    [self notifyObserverOf:CoordinatorNotificationNewShippingAddress];
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
    [self automaticUpdateOrderInfo];
    
    [self notifyObserverOf:CoordinatorNotificationNewPaymentType];
}

- (void)orderManagerDidChangeVenue{
    [self automaticUpdateOrderInfo];
    
    [self notifyObserverOf:CoordinatorNotificationNewVenue];
}

- (void)orderManagerDidChangeComment{
    [self notifyObserverOf:CoordinatorNotificationNewComment];
}

- (void)orderManagerDidChangeOddSum{
    [self notifyObserverOf:CoordinatorNotificationNewOddSum];
}

- (void)orderManagerDidChangePersonsCount{
    [self notifyObserverOf:CoordinatorNotificationNewPersonsCount];
}

- (void)orderManagerDidChangeNDAAccept{
    [self notifyObserverOf:CoordinatorNotificationNDAAccept];
}

- (void)orderManagerDidChangeConfirmationType {
    [self notifyObserverOf:CoordinatorNotificationNewConfirmationType];
}

#pragma mark - DeliverySettings changes

- (void)deliverySettingsDidChangeDeliveryType{
    [self automaticUpdateOrderInfo];
    
    [self notifyObserverOf:CoordinatorNotificationNewDeliveryType];
}

- (void)deliverySettingsDidChangeTime{
    [self automaticUpdateOrderInfo];
    
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
