//
//  IHSecureStore.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 12.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "IHSecureStore.h"
#import "UICKeyChainStore.h"
#import "DBAPIClient.h"
#import "DBServerAPI.h"
#import "DBCardsManager.h"
#import <Crashlytics/Crashlytics.h>

@interface IHSecureStore ()
@property(strong, nonatomic) UICKeyChainStore *secureStore;
@end

@implementation IHSecureStore

+ (id)sharedInstance
{
    static IHSecureStore *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [IHSecureStore new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    self.secureStore = [UICKeyChainStore keyChainStoreWithService:[[NSBundle mainBundle] bundleIdentifier] accessGroup:[NSString stringWithFormat:@"WDRAVGQ9R2.%@", [[NSBundle mainBundle] bundleIdentifier]]];
    
#ifdef DEBUG
//    [self.secureStore removeAllItems];
#endif
    
    return self;
}

- (void)setClientId:(NSString *)clientId{
    if(clientId && ![clientId isEqualToString:@"0"] && ![clientId isEqualToString:@""]){
        [self.secureStore setString:clientId forKey:@"clientId"];
        [self.secureStore synchronize];
        
        // Track clientId with crashes
        [[Crashlytics sharedInstance] setUserIdentifier:clientId];
        [DBAPIClient sharedClient].clientHeaderEnabled = YES;
    }
}

- (NSString *)clientId {
    NSString *clientId;

    clientId = self.secureStore[@"clientId"];

    
    if ([clientId isEqualToString:@"0"]) {
        return nil;
    } else {
        return clientId;
    }
}

- (NSString *)paymentClientId {
    NSString *paymentClientId;
    
    paymentClientId = self.secureStore[@"paymentClientId"];
    
    if (paymentClientId.length == 0) {
        NSString *clientId = self.clientId;
        if (clientId.length > 0) {
            [self.secureStore setString:clientId forKey:@"paymentClientId"];
            [self.secureStore synchronize];
        }
        paymentClientId = self.secureStore[@"paymentClientId"];
    }
    
    return paymentClientId;
}

- (NSData *)dataForKey:(NSString *)key {
    return [self.secureStore dataForKey:key];
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
    [self.secureStore setData:data forKey:key];
    [self.secureStore synchronize];
}

- (void)removeForKey:(NSString *)key {
    [self.secureStore removeItemForKey:key];
    [self.secureStore synchronize];
}

- (void)removeAll {
    [self.secureStore removeAllItems];
    [self.secureStore synchronize];
}

@end

@implementation IHSecureStore (Migration)
- (void)migrateDataAutomationRelease112 {
    UICKeyChainStore *oldStore = [UICKeyChainStore keyChainStoreWithService:[[NSBundle mainBundle] bundleIdentifier] accessGroup:@"WDRAVGQ9R2.com.empatka.doubleb"];
    
    void(^migratePayment)() = ^void() {
        NSData *data = [self dataForKey:@"payment_cards"];
        NSArray *cards = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (cards.count == 0) { // Move cards only if current cards count == 0
            NSData *oldCardsData = [oldStore dataForKey:@"payment_cards"];
            NSArray *oldCards = [NSKeyedUnarchiver unarchiveObjectWithData:oldCardsData];
            if (oldCards.count > 0) { // If old cards count > 0
                // Move cards
                [self.secureStore setData:oldCardsData forKey:@"payment_cards"];
                
                // Move payment client id, assotiated with cards
                NSString *paymentClientId = oldStore[@"paymentClientId"];
                if (paymentClientId.length > 0) {
                    [self.secureStore setString:paymentClientId forKey:@"paymentClientId"];
                }
            }
        }
    };
    
    NSString *clientId = oldStore[@"clientId"];
    if (clientId.length > 0) {
        if (self.clientId) {
            [DBServerAPI recoverClientId:self.clientId fromId:clientId callback:^(BOOL success) {
                if (success) {
                    migratePayment();
                    
                    [self.secureStore synchronize];
                    
                    [oldStore removeAllItems];
                    [oldStore synchronize];
                }
            }];
        } else {
            [self.secureStore setString:clientId forKey:@"clientId"];
            
            migratePayment();
            
            [self.secureStore synchronize];
            
            [oldStore removeAllItems];
            [oldStore synchronize];
        }
    }
}

- (void)migrateIIkoFlagAutomationRelease112 {
    UICKeyChainStore *oldStore = [UICKeyChainStore keyChainStoreWithService:[[NSBundle mainBundle] bundleIdentifier] accessGroup:@"WDRAVGQ9R2.com.empatka.doubleb"];
    
    // Save flag if iiko cache was cleared
    NSData *flagData = [oldStore dataForKey:@"kDBVersionDependencyManagerRemovedIIkoCache"];
    if (flagData) {
        [self.secureStore setData:flagData forKey:@"kDBVersionDependencyManagerRemovedIIkoCache"];
        [self.secureStore synchronize];
        
        [oldStore removeItemForKey:@"kDBVersionDependencyManagerRemovedIIkoCache"];
        [oldStore synchronize];
    }
}

- (void)migrateIIkoData {
    // Fetch payment client Id from iiko app
    NSData *clientIdData = [self dataForKey:@"clientId"];
    // Save it as new payment Id
    [self setData:clientIdData forKey:@"paymentClientId"];
    
    // Remove iiko payment client Id
    [self removeForKey:@"clientId"];
    // Remove iiko client id (server return new)
    [self removeForKey:@"restoClientId"];
}

@end
