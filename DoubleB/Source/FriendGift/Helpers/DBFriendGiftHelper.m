//
//  DBShareHelper.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBFriendGiftHelper.h"
#import "DBAPIClient.h"
#import "DBCardsManager.h"
#import "IHSecureStore.h"
#import "DBClientInfo.h"
#import "DBMenuPosition.h"
#import "OrderItem.h"

#import "AKNumericFormatter.h"

NSString * const DBFriendGiftHelperNotificationFriendName = @"DBFriendGiftHelperNotificationFriendName";
NSString * const DBFriendGiftHelperNotificationFriendPhone = @"DBFriendGiftHelperNotificationFriendPhone";

NSString * const DBFriendGiftHelperNotificationItemsPrice = @"DBFriendGiftHelperNotificationItemsPrice";
NSString * const DBFriendGiftHelperNotificationItemsCount = @"DBFriendGiftHelperNotificationItemsCount";

@implementation DBFriendGiftHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        self.friendName = [DBUserName new];
        self.friendPhone = [DBUserPhone new];
        
        [self.friendName addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
        [self.friendPhone addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
        
        _itemsManager = [[OrderItemsManager alloc] initWithParentManager:self];
        _giftsHistory = @[];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableModule) name:kDBModulesManagerModulesLoaded object:nil];
        [self enableModule];
    }
    return self;
}

- (void)dealloc {
    [self.friendName removeObserver:self forKeyPath:@"value"];
    [self.friendPhone removeObserver:self forKeyPath:@"value"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if([keyPath isEqualToString:@"value"]) {
        if(object == self.friendName){
            [self notifyObserverOf:DBFriendGiftHelperNotificationFriendName];
        }
        
        if(object == self.friendPhone){
            [self notifyObserverOf:DBFriendGiftHelperNotificationFriendPhone];
        }
    }
}

- (void)manager:(id<OrderPartManagerProtocol>)manager haveChange:(NSInteger)changeType {
    // TODO: logic is not clear
    switch (changeType) {
        case ItemsManagerChangeTotalPrice: {
            [self notifyObserverOf:DBFriendGiftHelperNotificationItemsPrice];
            break;
        }
        case ItemsManagerChangeTotalCount: {
            [[NSNotificationCenter defaultCenter] postNotificationName:DBFriendGiftHelperNotificationItemsCount object:nil];
            break;
        }
        default:
            break;
    }
}

- (void)enableModule {
    DBModule *module;
    
    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypeFriendGiftMivako]) {
        module = [[DBModulesManager sharedInstance] module:DBModuleTypeFriendGiftMivako];
        
        [DBFriendGiftHelper setValue:@(DBFriendGiftTypeFree) forKey:@"type"];
    }
    
    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypeFriendGift]) {
        module = [[DBModulesManager sharedInstance] module:DBModuleTypeFriendGift];
        
        [DBFriendGiftHelper setValue:@(DBFriendGiftTypeCommon) forKey:@"type"];
    }
    
    if (module) {
        [DBFriendGiftHelper setValue:@(YES) forKey:@"enabled"];
        
        [DBFriendGiftHelper setValue:([module.info getValueForKey:@"title"] ?: @"") forKey:@"titleFriendGiftScreen"];
        [DBFriendGiftHelper setValue:([module.info getValueForKey:@"text"] ?: @"") forKey:@"textFriendGiftScreen"];
        
        [self fetchItems:nil];
    } else {
        [DBFriendGiftHelper setValue:@(NO) forKey:@"enabled"];
    }
}

- (void)processGift:(void(^)(NSString *smsText))success
            failure:(void(^)(NSString *errorDescription))failure {
    if(!self.validData){
        if(failure)
            failure(nil);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if(self.friendName)
        params[@"recipient_name"] = self.friendName.value;
    if(self.friendPhone)
        params[@"recipient_phone"] = self.friendPhone.value;
    
    if(self.type == DBFriendGiftTypeCommon && [DBCardsManager sharedInstance].defaultCard){
        params[@"payment_type_id"] = @1;
        params[@"alpha_client_id"] = [IHSecureStore sharedInstance].paymentClientId;
        params[@"binding_id"] = [DBCardsManager sharedInstance].defaultCard.token;
        params[@"return_url"] = @"alpha-payment://return-page";
    }
    
    if([DBClientInfo sharedInstance].clientPhone.valid){
        params[@"sender_phone"] = [DBClientInfo sharedInstance].clientPhone.value;
    }
    if([DBClientInfo sharedInstance].clientMail.valid){
        params[@"sender_mail"] = [DBClientInfo sharedInstance].clientMail.value;
    }
    
    NSMutableArray *items = [NSMutableArray new];
    for (OrderItem *item in self.itemsManager.items) {
        [items addObject:[item requestJson]];
    }
    params[@"items"] = [items encodedString];
    params[@"total_sum"] = @(self.itemsManager.totalPrice);
    
    
    NSString *url = self.type == DBFriendGiftTypeCommon ? @"shared/gift/get_url" : @"shared/gift/get_mivako_url";
    [[DBAPIClient sharedClient] POST:url
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 
                                 NSString *smsText = [responseObject getValueForKey:@"sms_text"];
                                 
                                 if(success)
                                     success(smsText);
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 NSString *message;
                                 if(operation.response.statusCode == 400){
                                     message = operation.response.description;
                                 } else {
                                     message = NSLocalizedString(@"NoInternetConnectionErrorMessage", nil);
                                 }
                                 
                                 if(failure)
                                     failure(message);
                             }];
}

- (void)fetchItems:(void(^)(BOOL success))callback {
    [[DBAPIClient sharedClient] GET:@"shared/gift/items"
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 
                                 NSMutableArray *items = [NSMutableArray new];
                                 for (NSDictionary *itemDict in responseObject[@"items"]) {
                                     DBMenuPosition *position = [[DBMenuPosition alloc] initWithResponseDictionary:itemDict];
                                     [items addObject:position];
                                 }
                                 NSData *dataItems = [NSKeyedArchiver archivedDataWithRootObject:items];
                                 [DBFriendGiftHelper setValue:dataItems forKey:@"itemsData"];
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 if(callback)
                                     callback(NO);
                             }];
}

- (void)fetchGiftsHistory:(void (^)(BOOL))callback {
    [[DBAPIClient sharedClient] GET:@"shared/gift/history"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(callback)
                                    callback(NO);
                            }];
}

- (BOOL)validData {
    BOOL result = YES;
    
    NSString *mask = @"+* (***) ***-**-**";
    NSString *reformattedString = [AKNumericFormatter formatString:self.friendPhone.value
                                                         usingMask:mask
                                              placeholderCharacter:'*'];
    BOOL phoneIsValid =  [[AKNumericFormatter formatterWithMask:mask placeholderCharacter:'*'] isFormatFulfilled:reformattedString];
    
    result = result && self.itemsManager.totalCount > 0;
    result = result && self.friendName.valid;
    result = result && self.friendPhone.valid && phoneIsValid;
    
    if (self.type == DBFriendGiftTypeCommon) {
        result = result && [DBCardsManager sharedInstance].defaultCard;
    }
    
    return result;
}

- (BOOL)enabled {
    return [[DBFriendGiftHelper valueForKey:@"enabled"] boolValue];
}

- (DBFriendGiftType)type {
    return [[DBFriendGiftHelper valueForKey:@"type"] intValue];
}

- (NSString *)titleFriendGiftScreen {
    return [DBFriendGiftHelper valueForKey:@"titleFriendGiftScreen"];
}

- (NSString *)textFriendGiftScreen {
    return [DBFriendGiftHelper valueForKey:@"textFriendGiftScreen"];
}

- (NSArray *)items {
    NSData *itemsData = [DBFriendGiftHelper valueForKey:@"itemsData"];
    
    NSArray *items = @[];
    if(itemsData){
        items = [NSKeyedUnarchiver unarchiveObjectWithData:itemsData];
    }
    
    return items;
}

#pragma mark - DBPrimaryManager

+ (NSString *)db_managerStorageKey {
    return @"kDBDefaultsDBFriendGiftHelperInfo";
}

@end
