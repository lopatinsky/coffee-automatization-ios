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


NSString * const DBFriendGiftHelperNotificationFriendName = @"DBFriendGiftHelperNotificationFriendName";
NSString * const DBFriendGiftHelperNotificationFriendPhone = @"DBFriendGiftHelperNotificationFriendPhone";

@implementation DBFriendGiftHelper
- (instancetype)init {
    self = [super init];
    if (self) {
        self.friendName = [DBUserName new];
        self.friendPhone = [DBUserPhone new];
        
        [self.friendName addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
        [self.friendPhone addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if([keyPath isEqualToString:@"value"]){
        if(object == self.friendName){
            [self notifyObserverOf:DBFriendGiftHelperNotificationFriendName];
        }
        
        if(object == self.friendPhone){
            [self notifyObserverOf:DBFriendGiftHelperNotificationFriendPhone];
        }
    }
}

- (void)dealloc {
    [self.friendName removeObserver:self forKeyPath:@"value"];
    [self.friendPhone removeObserver:self forKeyPath:@"value"];
}

- (void)enableModule:(BOOL)enabled withDict:(NSDictionary *)moduleDict {
    [DBFriendGiftHelper setValue:@(enabled) forKey:@"enabled"];
    
//                                _titleFriendGiftScreen = responseObject[@"head"];
//                                _textFriendGiftScreen = responseObject[@"text"];
}


- (void)processGift:(void(^)(NSString *smsText))success
            failure:(void(^)(NSString *errorDescription))failure {
    if(self.validData){
        if(failure)
            failure(nil);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if(self.friendName)
        params[@"recipient_name"] = self.friendName.value;
    if(self.friendPhone)
        params[@"recipient_phone"] = self.friendPhone.value;
    
    if([DBCardsManager sharedInstance].defaultCard){
        params[@"payment_type_id"] = @1;
        params[@"alpha_client_id"] = [IHSecureStore sharedInstance].clientId;
        params[@"binding_id"] = [DBCardsManager sharedInstance].defaultCard.token;
        params[@"return_url"] = @"alpha-payment://return-page";
    }
    
    if([DBClientInfo sharedInstance].clientPhone.valid){
        params[@"sender_phone"] = [DBClientInfo sharedInstance].clientPhone.value;
    }
    if([DBClientInfo sharedInstance].clientMail.valid){
        params[@"sender_mail"] = [DBClientInfo sharedInstance].clientMail.value;
    }
    
    [[DBAPIClient sharedClient] POST:@"shared/gift/get_url"
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 
                                 self.smsText = responseObject[@"sms_text"];
                                 
                                 if(success)
                                     success(self.smsText);
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
    [[DBAPIClient sharedClient] POST:@"shared/gift/items"
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 
                                 NSMutableArray *items = [NSMutableArray new];
                                 for (NSDictionary *itemDict in responseObject[@"items"]) {
                                     DBMenuPosition *position = [[DBMenuPosition alloc] initWithResponseDictionary:itemDict];
                                     [items addObject:position];
                                 }
                                 _items = items;
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 if(callback)
                                     callback(NO);
                             }];
}

- (BOOL)validData {
    BOOL result = YES;
    
    result = result && self.itemsManager.totalCount > 0;
    result = result && self.friendName.valid;
    result = result && self.friendPhone.valid;
    result = result && [DBCardsManager sharedInstance].defaultCard;
    
    return result;
}

- (BOOL)enabled {
    return [[DBFriendGiftHelper valueForKey:@"enabled"] boolValue];
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

- (void)saveItems:(NSDictionary *)items {
    for (NSDictionary *itemDict in items){
    }
}

- (NSString *)smsText {
    return [DBFriendGiftHelper valueForKey:@"smsText"];
}

- (void)setSmsText:(NSString *)smsText {
    [DBFriendGiftHelper setValue:smsText forKey:@"smsText"];
}

#pragma mark - DBPrimaryManager

+ (NSString *)db_managerStorageKey {
    return @"kDBDefaultsDBFriendGiftHelperInfo";
}

@end
