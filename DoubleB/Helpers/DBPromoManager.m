//
//  PromoManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 11.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPromoManager.h"
#import "DBServerAPI.h"
#import "IHSecureStore.h"
#import "OrderManager.h"
#import "DBMenu.h"
#import "DBMenuPosition.h"

NSString *const kDBDefaultsPersonalWalletInfo = @"kDBDefaultsPersonalWalletInfo";

@implementation DBPromoItem

@end


@interface DBPromoManager ()
@property (nonatomic) double discount;
@property (nonatomic) double bonuses;
@property (nonatomic) double totalDiscount;

@property (strong, nonatomic) NSMutableArray *promoItems;

@property (nonatomic) NSInteger lastUpdateNumber;
@end

@implementation DBPromoManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static DBPromoManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lastUpdateNumber = 0;
        _validOrder = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:kDBNewOrderCreatedNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (double)totalDiscount{
    return _discount + (_bonusesActive ? _bonuses : 0);
}

- (void)changeTotalDiscount{
    [self willChangeValueForKey:@"totalDiscount"];
    [self didChangeValueForKey:@"totalDiscount"];
}

- (void)setBonusesActive:(BOOL)bonusesActive{
    _bonusesActive = bonusesActive;
    [self changeTotalDiscount];
}

- (void)updateInfo:(void(^)(BOOL success))callback {
    if (![IHSecureStore sharedInstance].clientId) {
        if(callback)
            callback(NO);
        return;
    }
    
    NSInteger currentUpdateNumber = self.lastUpdateNumber + 1;
    self.lastUpdateNumber = currentUpdateNumber;
    

    double currentTotal = [OrderManager sharedManager].totalPrice;
    [DBServerAPI checkNewOrder:^(NSDictionary *response) {
        // Calculate discount
        double newTotal = [response[@"total_sum"] doubleValue];
        self.discount = currentTotal - newTotal;
        
        // Calculate bonuses
        self.bonuses = [response[@"max_wallet_payment"] doubleValue];
        
        [self changeTotalDiscount];
        
        // Assemble global promos & errors
        NSMutableArray *globalPromoMessages = [NSMutableArray new];
        NSMutableArray *globalErrorsMessages = [NSMutableArray new];
        
        for(NSString *error in response[@"errors"]){
            [globalErrorsMessages addObject:error];
        }
        
        for (NSDictionary *promo in response[@"promos"]) {
            [globalPromoMessages addObject:promo[@"text"]];
        }
        _promos = globalPromoMessages;
        _errors = globalErrorsMessages;
        
        
        // Assemble items promos & errors
        [self.promoItems removeAllObjects];
        for(NSDictionary *item in response[@"items"]){
            DBMenuPosition *templatePosition = [[[DBMenu sharedInstance] findPositionWithId:item[@"id"]] copy];
            
            for(NSDictionary *groupModifierItem in item[@"group_modifiers"]){
                [templatePosition selectItem:groupModifierItem[@"choice"]
                            forGroupModifier:groupModifierItem[@"id"]];
            }
            
            for(NSDictionary *singleModifier in item[@"single_modifiers"]){
                [templatePosition addSingleModifier:singleModifier[@"id"] count:[singleModifier[@"quantity"] intValue]];
            }
            
            OrderItem *orderItem = [[OrderManager sharedManager] itemWithTemplatePosition:templatePosition];
            if(item){
                DBPromoItem *promoItem = [DBPromoItem new];
                promoItem.orderItem = orderItem;
            
                NSMutableArray *itemPromos = [NSMutableArray new];
                for(NSDictionary *itemPromo in item[@"promos"]){
                    [itemPromos addObject:itemPromo[@"text"]];
                }
                promoItem.promos = itemPromos;
                
                promoItem.errors = item[@"errors"];
                
                [self.promoItems addObject:promoItem];
            }
        }
        
        _validOrder = [response[@"valid"] boolValue];
        if(self.lastUpdateNumber == currentUpdateNumber && callback){
            callback(YES);
        }
    } failure:^(NSError *error) {
        _validOrder = NO;
        
        if(self.lastUpdateNumber == currentUpdateNumber && callback){
            callback(NO);
        }
    }];
}

- (void)clear{
    self.discount = 0;
    self.bonuses = 0;
    [self changeTotalDiscount];
}

- (DBPromoItem *)promosForOrderItem:(OrderItem *)item {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderItem == %@", item];
    DBPromoItem *promoItem = [[self.promoItems filteredArrayUsingPredicate:predicate] firstObject];
    
    return promoItem;
}


#pragma mark - Wallet

- (void)synchronizeWalletInfo:(void(^)(int balance))callback{
    [DBServerAPI getWalletInfo:^(BOOL success, NSDictionary *response) {
        if(success){
            double walletBalance = [response[@"balance"] doubleValue];
            
            NSMutableDictionary *walletInfo = [NSMutableDictionary new];
            walletInfo[@"balance"] = @(walletBalance);
            
            [self saveWalletInfo:walletInfo];
            
            if(callback)
                callback(walletBalance);
        }
    }];
}

- (NSInteger)walletBalance{
    NSDictionary *walletInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsPersonalWalletInfo];
    
    return [walletInfo[@"balance"] doubleValue];
}

- (void)saveWalletInfo:(NSDictionary *)info{
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:kDBDefaultsPersonalWalletInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
