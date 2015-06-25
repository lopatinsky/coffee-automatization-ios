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
#import "DBMenuBonusPosition.h"


@implementation DBPromotion
@end

@implementation DBPromoItem
- (void)clear{
    self.orderItem = nil;
    self.errors = @[];
    self.promos = @[];
    self.substitute = nil;
}
@end


@interface DBPromoManager ()
@property (nonatomic) double walletBalance;

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
        
        [self loadFromMemory];
        self.promoItems = [NSMutableArray new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:kDBNewOrderCreatedNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Static info for promos

- (void)updateInfo{
    [DBServerAPI updatePromoInfo:^(NSDictionary *response) {
        // List of promos
        NSMutableArray *promotionList = [NSMutableArray new];
        for(NSDictionary *promotionDict in response[@"promos"]){
            DBPromotion *promotion = [DBPromotion new];
            promotion.promotionName = [promotionDict getValueForKey:@"title"] ?: @"";
            promotion.promotionDescription = [promotionDict getValueForKey:@"description"] ?: @"";
            
            [promotionList addObject:promotion];
        }
        _promotionList = promotionList;
        
        // Bonus Positions promo
        NSDictionary *bonusPositionsPromo = response[@"bonuses"];
        
        NSMutableArray *bonusPositions = [NSMutableArray new];
        for(NSDictionary *bonusPositionDict in bonusPositionsPromo[@"items"]){
            DBMenuBonusPosition *bonusPosition = [[DBMenuBonusPosition alloc] initWithResponseDictionary:bonusPositionDict];
            
            if(bonusPosition){
                bonusPosition.pointsPrice = [bonusPositionDict[@"points"] doubleValue];
                [bonusPositions addObject:bonusPosition];
            }
        }
        [bonusPositions sortUsingComparator:^NSComparisonResult(DBMenuBonusPosition *obj1, DBMenuBonusPosition *obj2) {
            return [@(obj1.pointsPrice) compare:@(obj2.pointsPrice)];
        }];
        _positionsAvailableAsBonuses = bonusPositions;
        
//        DBMenuPosition *position1 = [[DBMenu sharedInstance] findPositionWithId:@"4855880898052096"];
//        DBMenuBonusPosition *bonusPosition1 = [[DBMenuBonusPosition alloc] initWithResponseDictionary:position1.productDictionary];
//        bonusPosition1.pointsPrice = 3;
//        
//        DBMenuPosition *position2 = [[DBMenu sharedInstance] findPositionWithId:@"6020882187157504"];
//        DBMenuBonusPosition *bonusPosition2 = [[DBMenuBonusPosition alloc] initWithResponseDictionary:position2.productDictionary];
//        bonusPosition2.pointsPrice = 4;
//        _positionsAvailableAsBonuses = @[bonusPosition1, bonusPosition2];
        
        _bonusPositionsTextDescription = bonusPositionsPromo[@"text"];
        
        // Personal wallet promo
        NSDictionary *personalWalletPromo = response[@"wallet"];
        _walletEnabled = [personalWalletPromo[@"enable"] boolValue];
        _walletTextDescription = personalWalletPromo[@"text"];
        [self updatePersonalWalletBalance:nil];
        
        [self synchronize];
    } failure:^(NSError *error) {
    }];
}


#pragma mark - Check of Current Order

- (double)totalDiscount{
    return _discount + (_walletActiveForOrder ? _walletPointsAvailableForOrder : 0);
}

- (void)changeTotalDiscount{
    [self willChangeValueForKey:@"totalDiscount"];
    [self didChangeValueForKey:@"totalDiscount"];
}

- (BOOL)checkCurrentOrder:(void(^)(BOOL success))callback {
    if (![IHSecureStore sharedInstance].clientId) {
        return NO;
    }
    
    NSInteger currentUpdateNumber = self.lastUpdateNumber + 1;
    self.lastUpdateNumber = currentUpdateNumber;

    double currentTotal = [OrderManager sharedManager].totalPrice;
    [DBServerAPI checkNewOrder:^(NSDictionary *response) {
        if(self.lastUpdateNumber == currentUpdateNumber && callback){
            // bonus points balance
            _bonusPointsBalance = [[response getValueForKey:@"full_points"] doubleValue];
            _bonusPositionsAvailable = [[response getValueForKey:@"more_gift"] boolValue];
            
            // Calculate discount
            double newTotal = [response[@"total_sum"] doubleValue];
            _discount = currentTotal - newTotal;
            
            // Calculate wallet points available for order
            [self willChangeValueForKey:@"walletPointsAvailableForOrder"];
            _walletPointsAvailableForOrder = [response[@"max_wallet_payment"] doubleValue];
            [self didChangeValueForKey:@"walletPointsAvailableForOrder"];
            
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
            
            // Show shipping total in promos list
            self.shippingPrice = [[response getValueForKey:@"delivery_sum"] doubleValue];
            
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
                
                    // Promos
                    NSMutableArray *itemPromos = [NSMutableArray new];
                    for(NSDictionary *itemPromo in item[@"promos"]){
                        [itemPromos addObject:itemPromo[@"text"]];
                    }
                    promoItem.promos = itemPromos;
                    
                    // Errors
                    promoItem.errors = item[@"errors"];
                    
                    // Substitutes
                    NSArray *substitutes = item[@"substitutes"];
                    if(substitutes && substitutes.count > 0){
                        NSDictionary *substitute = [substitutes firstObject];
                        if(substitute){
                            NSString *positionId = substitute[@"item_id"];
                            DBMenuPosition *position = [[DBMenu sharedInstance] findPositionWithId:positionId];
                            if(position){
                                promoItem.substitute = position;
                                promoItem.replaceToSubstituteAutomatic = [substitute[@"auto_replace"] boolValue];
                                promoItem.errors = @[substitute[@"description"]];
                            }
                        }
                    }
                    
                    [self.promoItems addObject:promoItem];
                }
            }
            
            // Assemble gift positions for order
            
            _validOrder = [response[@"valid"] boolValue];
        
            callback(YES);
        }
    } failure:^(NSError *error) {
        _validOrder = NO;
        
        if(self.lastUpdateNumber == currentUpdateNumber && callback){
            callback(NO);
        }
    }];
    
    return YES;
}

- (void)clear{
    _shippingPrice = 0;
    _discount = 0;
    _walletPointsAvailableForOrder = 0;
    [self changeTotalDiscount];
}

- (DBPromoItem *)promosForOrderItem:(OrderItem *)item {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderItem == %@", item];
    DBPromoItem *promoItem = [[self.promoItems filteredArrayUsingPredicate:predicate] firstObject];
    
    return promoItem;
}


#pragma mark - Personal Wallet promo

- (void)updatePersonalWalletBalance:(void(^)(double balance))callback{
    [DBServerAPI getWalletInfo:^(BOOL success, NSDictionary *response) {
        if(success){
            self.walletBalance = [response[@"balance"] doubleValue];
            
            [self synchronize];
            
            if(callback)
                callback(self.walletBalance);
        }
    }];
}

- (void)setWalletActiveForOrder:(BOOL)walletActiveForOrder{
    _walletActiveForOrder = walletActiveForOrder;
    [self changeTotalDiscount];
}


#pragma mark - Helper methods

- (void)loadFromMemory{
    NSDictionary *promoInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsPromoInfo];
    
    NSDictionary *bonusPositionsPromo = promoInfo[@"bonusPositionsPromo"];
    NSData *positionsAvailableAsBonuses = bonusPositionsPromo[@"positionsAvailableAsBonuses"];
    _positionsAvailableAsBonuses = [NSKeyedUnarchiver unarchiveObjectWithData:positionsAvailableAsBonuses] ?: @[];
    _bonusPositionsTextDescription = bonusPositionsPromo[@"bonusPositionsTextDescription"] ?: @"";
    
    NSDictionary *personalWalletPromo = promoInfo[@"personalWalletPromo"];
    _walletEnabled = [personalWalletPromo[@"walletEnabled"] boolValue];
    _walletBalance = [personalWalletPromo[@"walletBalance"] boolValue];
    _walletTextDescription = personalWalletPromo[@"walletTextDescription"] ?: @"";
}

- (void)synchronize{
    NSData *positionsAvailableAsBonuses = [NSKeyedArchiver archivedDataWithRootObject:_positionsAvailableAsBonuses];
    NSDictionary *bonusPositionsPromo = @{@"positionsAvailableAsBonuses": positionsAvailableAsBonuses,
                                          @"bonusPositionsTextDescription": _bonusPositionsTextDescription};
    
    NSDictionary *personalWalletPromo = @{@"walletEnabled": @(_walletEnabled),
                                          @"walletBalance": @(_walletBalance),
                                          @"walletTextDescription": _walletTextDescription};
    
    NSDictionary *promoInfo = @{@"bonusPositionsPromo": bonusPositionsPromo,
                                @"personalWalletPromo": personalWalletPromo};
    
    [[NSUserDefaults standardUserDefaults] setObject:promoInfo forKey:kDBDefaultsPromoInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
