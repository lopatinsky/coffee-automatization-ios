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
    
    self.secureStore = [UICKeyChainStore keyChainStore];
//    [self.secureStore removeAllItems];
    
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

- (NSArray *)cards {
    return [self mutableCards];
}

- (NSMutableArray *)mutableCards {
    NSData *data = [self.secureStore dataForKey:@"cards"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSDictionary *)defaultCard {
    NSArray *cards = [self cards];
    NSDictionary *def = nil;
    for (NSDictionary *card in cards) {
        if ([card[@"default"] boolValue]) {
            def = card;
        }
    }
    if (!def && [cards count] > 0) {
        def = cards[0];
        [self setDefaultCardWithBindingId:def[@"cardToken"]];
    }
    return def;
}

- (void)setDefaultCardWithBindingId:(NSString *)bindingId {
    NSMutableArray *cards = [self mutableCards];
    NSMutableDictionary *defaultCard = nil;
    NSMutableArray *resultCards = [NSMutableArray array];
    for (NSDictionary *card in cards) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:card];
        dict[@"default"] = @(NO);
        [resultCards addObject:dict];
        if ([dict[@"cardToken"] isEqualToString:bindingId]) {
            defaultCard = dict;
        }
    }
    if (defaultCard) {
        defaultCard[@"default"] = @(YES);
    }
    [self saveCards:resultCards];
}

- (void)saveCards:(NSMutableArray *)cards {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cards];
    [self.secureStore setData:data forKey:@"cards"];
    [self.secureStore synchronize];
}

- (NSUInteger)cardCount {
    NSMutableArray *cards = [self mutableCards];
    
    return cards == nil ? 0 : [cards count];
}

- (NSDictionary *)cardWithIndex:(NSUInteger)index{
    NSMutableArray *cards = [self mutableCards];
    
    return [cards count] > index ? cards[index] : nil;
}

-(BOOL)addCard:(NSString *)bindingId withPan:(NSString *)cardPan{
    NSMutableArray *cards = [self mutableCards];
    if(cards == nil)
        cards = [[NSMutableArray alloc] init];
    
    BOOL response = YES;
    for(NSDictionary *card in cards)
        response &= ![cardPan isEqualToString:card[@"cardPan"]];
    
    if(response){
        [cards addObject:@{
            @"cardToken": bindingId,
            @"default": @(NO),
            @"cardPan": cardPan
        }];
        [self saveCards:cards];
        
        [self setDefaultCardWithBindingId:bindingId];
    }
    
    return response;
}

- (void)removeCardAtIndex:(NSInteger)index{
    [GANHelper analyzeEvent:@"remove_card" category:PAYMENT_SCREEN];
    NSMutableArray *cards = [self mutableCards];
    
    if(cards == nil || [cards count] <= index)
        return;
    
    [cards removeObjectAtIndex:index];
    
    [self saveCards:cards];
}

@end
