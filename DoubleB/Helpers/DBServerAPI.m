//
//  DBServerAPI.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBServerAPI.h"
#import "DBAPIClient.h"
#import "OrderCoordinator.h"
#import "OrderItem.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"
#import "Order.h"
#import "Venue.h"
#import "IHSecureStore.h"
#import "DBCardsManager.h"
#import "DBClientInfo.h"
#import "Reachability.h"
#import "CoreDataHelper.h"
#import "DBClientInfo.h"
#import "DBPayPalManager.h"
#import "DBUnifiedAppManager.h"

#import "AppIndexingManager.h"
#import "WatchInteractionManager.h"
#import "DBUniversalModulesManager.h"
#import "DBUniversalModule.h"

#import <Parse/Parse.h>

@implementation DBServerAPI

#pragma mark - User

+ (void)requestCompanies:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    [[DBAPIClient sharedClient] GET:@"proxy/unified_app/companies"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                if(success)
                                    success(responseObject[@"companies"]);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(failure)
                                    failure(error);
                            }];
}

+ (void)registerUser:(void(^)(BOOL success))callback {
    [DBServerAPI registerUserWithBranchParams:nil callback:callback];
}

+ (void)registerUser:(CLLocation *)location callback:(void (^)(BOOL, DBCity *))callback {
    NSString *clientId = [IHSecureStore sharedInstance].clientId;
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if(clientId){
        params[@"client_id"] = clientId;
    }
    
    if (location) {
        params[@"ll"] = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    }
    
    [[DBAPIClient sharedClient] POST:@"register"
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 
                                 [[IHSecureStore sharedInstance] setClientId:[NSString stringWithFormat:@"%lld", (long long)[responseObject[@"client_id"] longLongValue]]];                             [[NSUserDefaults standardUserDefaults] synchronize];
                                 
                                 if(callback)
                                     callback(YES, nil);
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 if(callback)
                                     callback(NO, nil);
                             }];
}

+ (void)registerUserWithBranchParams:(NSDictionary *)branchParams callback:(void(^)(BOOL success))callback{
    NSString *clientId = [IHSecureStore sharedInstance].clientId;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    BOOL analytics = YES;
    if(clientId){
        params[@"client_id"] = clientId;
        analytics = NO;
    }
    
    if(branchParams && [branchParams count] != 0){
        NSData *shareData = [NSJSONSerialization dataWithJSONObject:branchParams
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
        NSString *shareDataString = [[NSString alloc] initWithData:shareData encoding:NSUTF8StringEncoding];
        params[@"share_data"] = shareDataString;
    }
    
    [[DBAPIClient sharedClient] POST:@"register"
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 
                                 [[IHSecureStore sharedInstance] setClientId:[NSString stringWithFormat:@"%lld", (long long)[responseObject[@"client_id"] longLongValue]]];
                                 
                                 
                                 if(analytics){
                                     [GANHelper analyzeEvent:@"user_register_success"
                                                       label:[IHSecureStore sharedInstance].clientId
                                                    category:APPLICATION_START];
                                 }
                                 
                                 if(callback)
                                     callback(YES);
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 if(analytics){
                                     [GANHelper analyzeEvent:@"user_register_failed"
                                                       label:error.description
                                                    category:APPLICATION_START];
                                 }
                                 
                                 if(callback)
                                     callback(NO);
                             }];
}

+ (void)sendUserInfo:(void(^)(BOOL success))callback {
    NSString *clientId = [[IHSecureStore sharedInstance] clientId];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    params[@"client_id"] = clientId;
    params[@"client_name"] = [DBClientInfo sharedInstance].clientName.value;
    params[@"client_phone"] = [DBClientInfo sharedInstance].clientPhone.value;
    params[@"client_email"] = [DBClientInfo sharedInstance].clientMail.value;
    
    NSMutableDictionary *universalModules = [NSMutableDictionary new];
    for (DBUniversalModule *module in [DBUniversalProfileModulesManager sharedInstance].modules) {
        universalModules[module.jsonField] = [module jsonRepresentation];
    }
    params[@"groups"] = [universalModules encodedString];
    
    if(clientId){
        [[DBAPIClient sharedClient] POST:@"client"
                              parameters:params
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     //NSLog(@"%@", responseObject);
                                     
                                     if(callback)
                                         callback(YES);
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     NSLog(@"%@", error);
                                     
                                     if(callback)
                                         callback(NO);
                                 }];
    }
}


#pragma mark - Company

+ (void)updateCompanyInfo:(void(^)(BOOL success, NSDictionary *response))callback{
    [[DBAPIClient sharedClient] GET:@"company/info"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                if(callback)
                                    callback(YES, responseObject);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(callback)
                                    callback(NO, nil);
                            }];
}


#pragma mark - Shipping Address

+ (void)requestAddressSuggestions:(NSDictionary *)params callback:(void(^)(BOOL success, NSArray *response))callback {
    [[DBAPIClient sharedClient] GET:@"address/by_street"
                         parameters:@{@"city": params[@"city"], @"street": params[@"street"]}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                if(callback)
                                    callback(YES, responseObject);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(callback)
                                    callback(NO, nil);
                            }];
}


#pragma mark - Promo Info

+ (void)updatePromoInfo:(void(^)(NSDictionary *response))success
                failure:(void(^)(NSError *error))failure{
    
    [[DBAPIClient sharedClient] GET:@"promo/list"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                NSLog(@"%@", responseObject);
                                
                                if(success)
                                    success(responseObject);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(failure)
                                    failure(error);
                            }];
}


#pragma mark - Order methods

+ (void)checkNewOrder:(void(^)(NSDictionary *response))success
              failure:(void(^)(NSError *error))failure {
    // TODO: check unused vars in checkNewOrder
    [[DBAPIClient sharedClient] POST:@"check_order"
                          parameters:[self assembleCheckOrderParams]
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 
                                 if(success)
                                     success(responseObject);
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 if(failure)
                                     failure(error);
                             }];
}

+ (void)createNewOrder:(void(^)(Order *order))success
               failure:(void(^)(NSString *errorTitle, NSString *errorMessage))failure {

    // Check if network connection is reachable
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(networkStatus == NotReachable){
        if(failure)
            failure(nil, NSLocalizedString(@"Невозможно разместить заказ. Пожалуйста, проверьте интернет-соединение", nil));
        return;
    }
    
    NSMutableDictionary *order = [self assembleNewOrderParams];
    
    static BOOL hasOrderErrorInSession = NO;
    order[@"after_error"] = @(hasOrderErrorInSession);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:order
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [GANHelper analyzeEvent:@"order_submit" category:ORDER_SCREEN];

    [[DBAPIClient sharedClient] POST:@"order"
                          parameters:@{@"order": jsonString}
                             timeout:30
                             success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 
                                 // Save order
                                 Order *ord = [[Order alloc] initNewOrderWithDict:responseObject];
                                 ord.requestObject = order;
                                 
                                 [[AppIndexingManager sharedManager] postActivity:ord withParams:@{@"type": @"order", @"expirationDate": [ord.time dateByAddingTimeInterval:60 * 60 * 24 * 7]}];
                                 for (OrderItem *item in [ord items]) {
                                     if ([item activityIsAvailable]) {
                                         [[AppIndexingManager sharedManager] postActivity:item withParams:@{@"type": @"position", @"expirationDate": [ord.time dateByAddingTimeInterval:60 * 60 * 24 * 7]}];
                                     }
                                 }
                                 
                                 [[WatchInteractionManager sharedInstance] updateLastOrActiveOrder];
                                 if(success)
                                     success(ord);
                                 
                                 // Send confirmation of success
                                 [self confirmOrderSuccess:ord.orderId];
                                 
                                 // Save user choice of modifiers on positions of order
                                 [[DBMenu sharedInstance] saveMenuToDeviceMemory];
                                 
                                 // Notify all about success order
                                 [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBNewOrderCreatedNotification object:ord]];
                                 
                                 hasOrderErrorInSession = NO;
                                 
                                 [[NSUserDefaults standardUserDefaults] setObject:ord.orderId forKey:@"lastOrderId"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 
                                 [Compatibility registerForNotifications];
                                 [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:[DBCompanyInfo sharedInstance].orderPushChannel, ord.orderId]];
                                 
                                 NSString *event;
                                 if(ord.paymentType == PaymentTypeCard){
                                     event = @"order_card_success";
                                 } else {
                                     event = @"order_success";
                                 }
                                 [GANHelper analyzeEvent:event
                                                   label:[NSString stringWithFormat:@"%@, %@", ord.orderId, [IHSecureStore sharedInstance].clientId]
                                                category:ORDER_SCREEN];
                                 
                                 [GANHelper trackNewOrderInfo:ord];
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 NSString *event;
                                 if([OrderCoordinator sharedInstance].orderManager.paymentType == PaymentTypeCard){
                                     event = @"order_card_failed";
                                 } else {
                                     event = @"order_failed";
                                 }
                                 [GANHelper analyzeEvent:event category:ORDER_SCREEN];
                                 
                                 if(failure){
                                     if (error.code == NSURLErrorTimedOut || operation.response.statusCode == 0){
                                         hasOrderErrorInSession = YES;
                                         
                                         failure(nil, NSLocalizedString(@"Нестабильное интернет-соединение. Возможно ваш заказ был успешно создан, пожалуйста, дождитесь подтверждения по смс и обновите историю", nil));
                                     } else if (operation.response.statusCode == 400) {
                                         NSString *title = operation.responseObject[@"title"] ?: NSLocalizedString(@"Ошибка", nil);
                                         failure(title, operation.responseObject[@"description"]);
                                       } else {
                                           failure(nil, NSLocalizedString(@"Произошла непредвиденная ошибка при регистрации заказа. Пожалуйста, попробуйте позднее", nil));
                                       }
                                 }
                             }];
    }

+ (void)confirmOrderSuccess:(NSString *)orderId{
    [[DBAPIClient sharedClient] POST:@"set_order_success"
                          parameters:@{@"order_id": orderId}
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                             }];
}


#pragma mark - History

+ (void)fetchOrdersHistory:(void(^)(BOOL success, NSError *error))callback{
    NSString *clientId = [[IHSecureStore sharedInstance] clientId];
    
    if(clientId){
        [[DBAPIClient sharedClient] GET:@"history"
                             parameters:@{@"client_id": clientId}
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    
                                    for(NSDictionary *orderDict in responseObject[@"orders"]){
                                        NSString *newOrderId = [NSString stringWithFormat:@"%@", orderDict[@"order_id"]];
                                        Order *sameOrder = [Order orderById:newOrderId];
                                        
                                        if(sameOrder){
                                            [sameOrder synchronizeWithResponseDict:orderDict];
                                        } else {
                                            Order *ord = [[Order alloc] initWithResponseDict:orderDict];
                                            
                                            [[NSUserDefaults standardUserDefaults] setObject:ord.orderId forKey:@"lastOrderId"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                            [Compatibility registerForNotifications];
                                            [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:[DBCompanyInfo sharedInstance].orderPushChannel, ord.orderId]];
                                        }
                                    }
                                    
                                    if(callback)
                                        callback(YES, nil);
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"%@", error);
                                    
                                    if(callback)
                                        callback(NO, nil);
                                }];
    }
}


#pragma mark - Wallet

+ (void)getWalletInfo:(void(^)(BOOL success, NSDictionary *response))callback{
    NSString *clientId = [IHSecureStore sharedInstance].clientId;
    if(!clientId){
        if(callback)
            callback(NO, nil);
        return;
    }
    
    [[DBAPIClient sharedClient] GET:@"wallet/balance"
                         parameters:@{@"client_id": clientId}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                if(callback)
                                    callback(YES, responseObject);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(callback)
                                    callback(NO, nil);
                            }];
}

#pragma mark - News 

+ (void)fetchCompanyNewsWithCallback:(void (^)(BOOL, NSDictionary *))callback {
    [[DBAPIClient sharedClient] GET:@"news"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                if (callback) {
                                    callback(YES, responseObject);
                                }
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(callback)
                                    callback(NO, nil);
                            }];
}

#pragma mark - Promo code 
+ (void)fetchActivatedPromoCodesWithCallback:(void (^)(BOOL, NSDictionary *))callback {
    [[DBAPIClient sharedClient] GET:[NSString stringWithFormat:@"promo_code/history?client_id=%@", [IHSecureStore sharedInstance].clientId]
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
                                if (callback) callback(YES, response);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                if (callback) callback(NO, nil);
                            }];
}

+ (void)activatePromoCode:(NSString *)code withCallback:(void (^)(BOOL, NSDictionary *))callback {
    [[DBAPIClient sharedClient] POST:@"promo_code/enter"
                         parameters:@{@"client_id": [IHSecureStore sharedInstance].clientId, @"key": code}
                            success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
                                if (callback) callback(YES, response);
                                
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                if (callback) callback(NO, nil);
                            }];
}

#pragma mark - Order assembly helpers

+ (NSMutableDictionary *)assembleNewOrderParams{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    // Client
    params[@"client"] = [DBServerAPI assembleClientInfo];
    
    // Items
    params[@"items"] = [DBServerAPI assembleOrderItems];
    
    // Bonus items
    params[@"gifts"] = [DBServerAPI assembleBonusItems];
    
    // Gift items
    params[@"order_gifts"]=[DBServerAPI assembleGiftItems];
    
    // Total
    params[@"total_sum"] = @([OrderCoordinator sharedInstance].itemsManager.totalPrice - [OrderCoordinator sharedInstance].promoManager.discount);
    
    // Shipping price
    params[@"delivery_sum"] = @([OrderCoordinator sharedInstance].promoManager.shippingPrice);
    
    // Payment
    if([OrderCoordinator sharedInstance].orderManager.paymentType != PaymentTypeNotSet){
        params[@"payment"] = [DBServerAPI assemblyPaymentInfo];
    }
    
    // Time
    [self assembleTimeIntoParams:params];
    
    // Delivery Type
    [self assembleDeliveryInfoIntoParams:params encode:NO];
    
    // Comment
    params[@"comment"] = [OrderCoordinator sharedInstance].orderManager.comment ?: @"";
    
    // Location
    if ([OrderCoordinator sharedInstance].orderManager.location) {
        CLLocation *location = [OrderCoordinator sharedInstance].orderManager.location;
        params[@"coordinates"] = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    }
    
    [self assembleExtraOrderInfoIntoParams:params encode:NO];
    
    // Device type
    params[@"device_type"] = @(0);
    
    return params;
}

+ (NSDictionary *)assembleCheckOrderParams{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    // Client
    if([IHSecureStore sharedInstance].clientId){
        params[@"client_id"] = [IHSecureStore sharedInstance].clientId;
    }
    
    // Items
    params[@"items"] = [[DBServerAPI assembleOrderItems] encodedString];
    
    // Bonus items
    params[@"gifts"] = [[DBServerAPI assembleBonusItems] encodedString];
    
//    // Gift items
//    params[@"order_gifts"]=[[DBServerAPI assembleGiftItems] encodedString];
    
    // Payment
    if([OrderCoordinator sharedInstance].orderManager.paymentType != PaymentTypeNotSet){
        params[@"payment"] = [[DBServerAPI assemblyPaymentInfo] encodedString];
    }
    
    // Time
    [self assembleTimeIntoParams:params];
    
    // Delivery Type
    [self assembleDeliveryInfoIntoParams:params encode:YES];
    
    [self assembleExtraOrderInfoIntoParams:params encode:YES];
    
    // Device type
    params[@"device_type"] = @(0);
    
    return params;
}

+ (NSArray *)assembleOrderItems{
    NSMutableArray *items = [NSMutableArray new];
    for (OrderItem *item in [OrderCoordinator sharedInstance].itemsManager.items) {
        [items addObject:[item requestJson]];
    }
    
    return items;
}

+ (NSArray *)assembleBonusItems{
    NSMutableArray *items = [NSMutableArray new];
    for (OrderItem *item in [OrderCoordinator sharedInstance].bonusItemsManager.items) {
        [items addObject:[item requestJson]];
    }
    
    return items;
}

+ (NSArray *)assembleGiftItems{
    NSMutableArray *items = [NSMutableArray new];
    for (OrderItem *item in [OrderCoordinator sharedInstance].orderGiftsManager.items) {
        [items addObject:[item requestJson]];
    }
    
    return items;
}

+ (NSDictionary *)assembleClientInfo {
    NSMutableDictionary *clientInfo = [NSMutableDictionary new];
    clientInfo[@"id"] = [[IHSecureStore sharedInstance] clientId];
    clientInfo[@"name"] =  [DBClientInfo sharedInstance].clientName.value;
    clientInfo[@"phone"] = [DBClientInfo sharedInstance].clientPhone.value;
    clientInfo[@"email"] = [DBClientInfo sharedInstance].clientMail.value;
    
    NSMutableDictionary *universalModules = [NSMutableDictionary new];
    for (DBUniversalModule *module in [DBUniversalProfileModulesManager sharedInstance].modules) {
        universalModules[module.jsonField] = [module jsonRepresentation];
    }
    clientInfo[@"groups"] = universalModules;
    
    return clientInfo;
}

+ (NSDictionary *)assemblyPaymentInfo {
    NSMutableDictionary *payment = [NSMutableDictionary new];
    
    PaymentType paymentType = [OrderCoordinator sharedInstance].orderManager.paymentType;
    payment[@"type_id"] = @(paymentType);
    
    if(paymentType == PaymentTypeCard){
        DBPaymentCard *card = [DBCardsManager sharedInstance].defaultCard;
        if(card){
            payment[@"binding_id"] = card.token;
            
            BOOL mcardOrMaestro = [card.cardIssuer isEqualToString:kDBCardTypeMasterCard] || [card.cardIssuer isEqualToString:kDBCardTypeMaestro];
            payment[@"mastercard"] = @(mcardOrMaestro);
            
            NSString *cardPan = card.pan;
            if(cardPan.length > 4){
                cardPan = [cardPan stringByReplacingCharactersInRange:NSMakeRange(0, cardPan.length - 4) withString:@""];
            }
            payment[@"card_pan"] = cardPan ?: @"";
        }
        
        payment[@"client_id"] = [IHSecureStore sharedInstance].paymentClientId;
        payment[@"return_url"] = @"alpha-payment://return-page";
    }
    
    if(paymentType == PaymentTypePayPal){
        payment[@"correlation_id"] = [DBPayPalManager sharedInstance].paymentMetadata ?: @"";
    }
    
    payment[@"wallet_payment"] = [OrderCoordinator sharedInstance].promoManager.walletActiveForOrder ? @([OrderCoordinator sharedInstance].promoManager.walletDiscount) : @(0);
    
    return payment;
}

+ (void)assembleTimeIntoParams:(NSMutableDictionary *)params {
    DeliverySettings *settings = [OrderCoordinator sharedInstance].deliverySettings;
    if(settings.deliveryType.timeMode & (TimeModeTime | TimeModeDateTime | TimeModeDateSlots)){
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        params[@"time_picker_value"] = [formatter stringFromDate:settings.selectedTime];
    }
    
    if(settings.deliveryType.timeMode & (TimeModeSlots | TimeModeDateSlots)){
        params[@"delivery_slot_id"] = settings.selectedTimeSlot.slotId;
    }
}

+ (void)assembleDeliveryInfoIntoParams:(NSMutableDictionary *)params encode:(BOOL)encode {
    DeliverySettings *settings = [OrderCoordinator sharedInstance].deliverySettings;
    params[@"delivery_type"] = @(settings.deliveryType.typeId);
    if(settings.deliveryType.typeId == DeliveryTypeIdShipping){
        NSDictionary *address = [OrderCoordinator sharedInstance].shippingManager.selectedAddress.jsonRepresentation;
        if(address){
            if(encode){
                params[@"address"] = [address encodedString];
            } else {
                params[@"address"] = address;
            }
        }
    } else {
        if([OrderCoordinator sharedInstance].orderManager.venue.venueId){
            params[@"venue_id"] = [OrderCoordinator sharedInstance].orderManager.venue.venueId;
        }
    }
}

+ (void)assembleExtraOrderInfoIntoParams:(NSMutableDictionary *)params encode:(BOOL)encode{
    params[@"num_people"] = [NSString stringWithFormat:@"%ld", (long)[OrderCoordinator sharedInstance].orderManager.personsCount];
    params[@"cash_change"] = [OrderCoordinator sharedInstance].orderManager.oddSum ?: @"";
    
    NSMutableDictionary *extraInfo = [NSMutableDictionary new];
    for (DBUniversalModule *module in [DBUniversalOrderModulesManager sharedInstance].modules) {
        extraInfo[module.jsonField] = [module jsonRepresentation];
    }
    params[@"extra_order_field"] = encode ? [extraInfo encodedString] : extraInfo;
}
            

@end
