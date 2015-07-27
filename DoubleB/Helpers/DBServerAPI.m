//
//  DBServerAPI.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBServerAPI.h"
#import "DBAPIClient.h"
#import "OrderManager.h"
#import "DBPromoManager.h"
#import "OrderItem.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"
#import "Order.h"
#import "Venue.h"
#import "IHSecureStore.h"
#import "DBClientInfo.h"
#import "Reachability.h"
#import "CoreDataHelper.h"
#import "Compatibility.h"
#import "DBClientInfo.h"
#import "DBPayPalManager.h"
#import "ShippingManager.h"

#import <Parse/Parse.h>

@implementation DBServerAPI

#pragma mark - User

+ (void)registerUser:(void(^)(BOOL success))callback{
    [DBServerAPI registerUserWithBranchParams:nil callback:callback];
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
                                 
                                 if(responseObject[@"share_type"]){
                                     int shareType = [responseObject[@"share_type"] intValue];
                                     switch (shareType) {
                                         case 0:// Share
                                             break;
                                         case 1:// Ivitation to app
                                             break;
                                         case 2:{// Friend gift
                                             NSString *branchName = responseObject[@"branch_name"];
                                             NSString *branchPhone = responseObject[@"branch_phone"];
                                             
                                             if(![[DBClientInfo sharedInstance] validClientName]){
                                                 [DBClientInfo sharedInstance].clientName = branchName;
                                             }
                                             
                                             if(![[DBClientInfo sharedInstance] validClientPhone]){
                                                 [DBClientInfo sharedInstance].clientPhone = branchPhone;
                                             }
                                             
//                                             [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBFriendGiftRecievedNotification object:nil]];
                                         }
                                             break;
                                     }
                                 }
                                 
//                                 BOOL branchGiftsPromoEnabled = [responseObject[@"branch_gifts"] boolValue];
//                                 [[NSUserDefaults standardUserDefaults] setObject:@(branchGiftsPromoEnabled)
//                                                                           forKey:kDBGiftForFriendPromoEnabled];
//                                 
//                                 BOOL branchInvitationsPromoEnabled = [responseObject[@"branch_invitations"] boolValue];
//                                 [[NSUserDefaults standardUserDefaults] setObject:@(branchInvitationsPromoEnabled)
//                                                                           forKey:kDBFreeBeveragesForSharePromoEnabled];
//                                 
//                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 
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

#pragma mark - Company

+ (void)updateCompanyInfo:(void(^)(BOOL success, NSDictionary *response))callback{
    [[DBAPIClient sharedClient] GET:@"company/info"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSMutableDictionary *response = [NSMutableDictionary new];
                                
                                response[@"appName"] = [responseObject getValueForKey:@"app_name"] ?: @"";
                                response[@"webSite"] = [responseObject getValueForKey:@"site"] ?: @"";
                                response[@"deliveryTypes"] = [responseObject getValueForKey:@"delivery_types"] ?: [NSArray new];
                                response[@"phone"] = [responseObject getValueForKey:@"phone"] ?: @"";
                                response[@"cities"] = [responseObject getValueForKey:@"cities"] ?: [NSArray new];
                                response[@"support_emails"] = [responseObject getValueForKey:@"emails"] ?: [NSArray new];
                                response[@"companyDescription"] = [responseObject getValueForKey:@"description"] ?: @"";
                                response[@"pushChannels"] = [responseObject getValueForKey:@"push_channels"] ?: @{};
                                response[@"companyType"] = responseObject[@"screen_logic_type"];
                                
                                if(callback)
                                    callback(YES, response);
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
                                NSLog(@"%@", responseObject);
                                
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
              failure:(void(^)(NSError *error))failure{
    
    [[DBAPIClient sharedClient] POST:@"check_order"
                          parameters:[self assembleCheckOrderParams]
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 
                                 if(success)
                                     success(responseObject);
                                 
                                 // Analitics
                                 if(responseObject){
                                     NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                                                            options:NSJSONWritingPrettyPrinted
                                                                                              error:nil];
                                     NSString *eventLabel = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                 }
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 if(failure)
                                     failure(error);
                                 
                                 // Analitics
                                 NSString *eventLabel = [NSString stringWithFormat:@"%ld", (long)error.code];
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
//                                 Order *ord = [[Order alloc] init:YES];
//                                 ord.orderId = [NSString stringWithFormat:@"%@", responseObject[@"order_id"]];
//                                 ord.total = @([[OrderManager sharedManager] totalPrice]);
//                                 ord.dataItems = [NSKeyedArchiver archivedDataWithRootObject:[OrderManager sharedManager].items];
//                                 ord.paymentType = [[OrderManager sharedManager] paymentType];
//                                 ord.status = OrderStatusNew;
//                                 ord.venue = [OrderManager sharedManager].venue;
//                                 
//                                 // Save Time
//                                 NSString *timeString = [responseObject getValueForKey:@"delivery_time"];
//                                 if(timeString){
//                                     NSDateFormatter *formatter = [NSDateFormatter new];
//                                     formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//                                     NSDate *date = [formatter dateFromString:timeString];
//                                     ord.time = date;
//                                 }
//                                 
//                                 NSString *timeSlot = [responseObject getValueForKey:@"delivery_slot_name"];
//                                 if(timeSlot){
//                                     ord.timeString = timeSlot;
//                                 }
//                                 
//                                 
//                                 [[CoreDataHelper sharedHelper] save];
                                 if(success)
                                     success(ord);
                                 
                                 // Send confirmation of success
                                 [self confirmOrderSuccess:ord.orderId];
                                 
                                 // Notify all about success order
                                 [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBNewOrderCreatedNotification object:nil]];
                                 
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
                                 if([OrderManager sharedManager].paymentType == PaymentTypeCard){
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

#pragma mark - Order assembly helpers

+ (NSMutableDictionary *)assembleNewOrderParams{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    // Client
    params[@"client"] = [DBServerAPI assembleClientInfo];
    
    // Items
    params[@"items"] = [DBServerAPI assembleOrderItems];
    
    // Bonus items
    params[@"gifts"] = [DBServerAPI assembleBonusItems];
    
    // Total
    params[@"total_sum"] = @([[OrderManager sharedManager] totalPrice] - [DBPromoManager sharedManager].discount);
    
    // Shipping price
    params[@"delivery_sum"] = @([DBPromoManager sharedManager].shippingPrice);
    
    // Payment
    if([OrderManager sharedManager].paymentType != PaymentTypeNotSet){
        params[@"payment"] = [DBServerAPI assemblyPaymentInfo];
    }
    
    // Time
    [self assembleTimeIntoParams:params];
    
    // Delivery Type
    [self assembleDeliveryInfoIntoParams:params encode:NO];
    
    // Comment
    params[@"comment"] = [OrderManager sharedManager].comment ?: @"";
    
    // Location
    if ([OrderManager sharedManager].location) {
        CLLocation *location = [OrderManager sharedManager].location;
        params[@"coordinates"] = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    }
    
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
    
    // Payment
    if([OrderManager sharedManager].paymentType != PaymentTypeNotSet){
        params[@"payment"] = [[DBServerAPI assemblyPaymentInfo] encodedString];
    }
    
    // Time
    [self assembleTimeIntoParams:params];
    
    // Delivery Type
    [self assembleDeliveryInfoIntoParams:params encode:YES];
    
    // Device type
    params[@"device_type"] = @(0);
    
    return params;
}

+ (NSArray *)assembleOrderItems{
    NSMutableArray *items = [NSMutableArray new];
    for (OrderItem *item in [OrderManager sharedManager].items) {
        [items addObject:[self assembleItem:item]];
    }
    
    return items;
}

+ (NSArray *)assembleBonusItems{
    NSMutableArray *items = [NSMutableArray new];
    for (OrderItem *item in [OrderManager sharedManager].bonusPositions) {
        [items addObject:[self assembleItem:item]];
    }
    
    return items;
}

+ (NSDictionary *)assembleItem:(OrderItem *)item {
    NSMutableDictionary *itemDict = [NSMutableDictionary new];
    
    itemDict[@"item_id"] = item.position.positionId;
    itemDict[@"quantity"] = @(item.count);
    
    NSMutableArray *singleModifiers = [NSMutableArray new];
    for(DBMenuPositionModifier *modifier in item.position.singleModifiers){
        [singleModifiers addObject:@{@"single_modifier_id": modifier.modifierId,
                                     @"quantity": @(modifier.selectedCount)}];
    }
    
    NSMutableArray *groupModifiers = [NSMutableArray new];
    for(DBMenuPositionModifier *modifier in item.position.groupModifiers){
        if(!modifier.selectedItem)
            continue;
        
        [groupModifiers addObject:@{@"group_modifier_id": modifier.modifierId,
                                    @"choice": modifier.selectedItem.itemId,
                                    @"quantity": @1}];
    }
    
    itemDict[@"single_modifiers"] = singleModifiers;
    itemDict[@"group_modifiers"] = groupModifiers;
    
    return itemDict;
}

+ (NSDictionary *)assembleClientInfo{
    NSMutableDictionary *clientInfo = [NSMutableDictionary new];
    clientInfo[@"id"] = [[IHSecureStore sharedInstance] clientId];
    clientInfo[@"name"] =  [DBClientInfo sharedInstance].clientName;
    clientInfo[@"phone"] = [DBClientInfo sharedInstance].clientPhone;
    clientInfo[@"email"] = [DBClientInfo sharedInstance].clientMail;
    
    return clientInfo;
}

+ (NSDictionary *)assemblyPaymentInfo{
    NSMutableDictionary *payment = [NSMutableDictionary new];
    
    payment[@"type_id"] = @([OrderManager sharedManager].paymentType);
    
    if([OrderManager sharedManager].paymentType == PaymentTypeCard){
        NSDictionary *card = [IHSecureStore sharedInstance].defaultCard;
        if(card[@"cardToken"]){
            payment[@"binding_id"] = card[@"cardToken"];
            
            BOOL mcardOrMaestro = [[card[@"cardPan"] db_cardIssuer] isEqualToString:kDBCardTypeMasterCard] || [[card[@"cardPan"] db_cardIssuer] isEqualToString:kDBCardTypeMaestro];
            payment[@"mastercard"] = @(mcardOrMaestro);
            
            NSString *cardPan = card[@"cardPan"];
            if(cardPan.length > 4){
                cardPan = [cardPan stringByReplacingCharactersInRange:NSMakeRange(0, cardPan.length - 4) withString:@""];
            }
            payment[@"card_pan"] = cardPan ?: @"";
        }
        payment[@"client_id"] = [[IHSecureStore sharedInstance] clientId];
        payment[@"return_url"] = @"alpha-payment://return-page";
    }
    
    if([OrderManager sharedManager].paymentType == PaymentTypePayPal){
        payment[@"correlation_id"] = [DBPayPalManager sharedInstance].paymentMetadata ?: @"";
    }
    
    payment[@"wallet_payment"] = [DBPromoManager sharedManager].walletActiveForOrder ? @([DBPromoManager sharedManager].walletPointsAvailableForOrder) : @(0);
    
    return payment;
}

+ (void)assembleTimeIntoParams:(NSMutableDictionary *)params{
    if([DBDeliverySettings sharedInstance].deliveryType.timeMode & (TimeModeTime | TimeModeDateTime | TimeModeDateSlots)){
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        params[@"time_picker_value"] = [formatter stringFromDate:[DBDeliverySettings sharedInstance].selectedTime];
    }
    
    if([DBDeliverySettings sharedInstance].deliveryType.timeMode & (TimeModeSlots | TimeModeDateSlots)){
        params[@"delivery_slot_id"] = [DBDeliverySettings sharedInstance].selectedTimeSlot.slotId;
    }
}

+ (void)assembleDeliveryInfoIntoParams:(NSMutableDictionary *)params encode:(BOOL)encode{
    params[@"delivery_type"] = @([DBDeliverySettings sharedInstance].deliveryType.typeId);
    if([DBDeliverySettings sharedInstance].deliveryType.typeId == DeliveryTypeIdShipping){
        NSDictionary *address = [DBShippingManager sharedManager].selectedAddress.jsonRepresentation;
        if(address){
            if(encode){
                params[@"address"] = [address encodedString];
            } else {
                params[@"address"] = address;
            }
        }
    } else {
        if([OrderManager sharedManager].venue.venueId){
            params[@"venue_id"] = [OrderManager sharedManager].venue.venueId;
        }
    }
}
            

@end
