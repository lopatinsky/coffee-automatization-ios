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
#import "OrderCoordinator.h"
#import "OrderItem.h"
#import "OrderItemsManager.h"
#import "DBMenu.h"
#import "DBMenuPosition.h"


@interface DBPromoManager ()
@property (nonatomic) double walletBalance;

@property (strong, nonatomic) NSMutableArray *promoItems;

@property (nonatomic) NSInteger lastUpdateNumber;

@property (weak, nonatomic) OrderCoordinator *parentManager;

@end

@implementation DBPromoManager

- (instancetype)initWithParentManager:(OrderCoordinator *)parentManager{
    self = [super init];
    if (self) {
        _parentManager = parentManager;
        
        self.lastUpdateNumber = 0;
        _validOrder = YES;
        
        [self loadFromMemory];
        self.promoItems = [NSMutableArray new];
    }
    
    return self;
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
        for (NSDictionary *bonusPositionDict in bonusPositionsPromo[@"items"]){
            DBMenuPosition *bonusPosition = [[DBMenuPosition alloc] initWithResponseDictionary:bonusPositionDict];
            
            if (bonusPosition){
                bonusPosition.mode = DBMenuPositionModeBonus;
                bonusPosition.price = [bonusPositionDict[@"points"] doubleValue];
                [bonusPositions addObject:bonusPosition];
            }
        }
        [bonusPositions sortUsingComparator:^NSComparisonResult(DBMenuPosition *obj1, DBMenuPosition *obj2) {
            return [@(obj1.price) compare:@(obj2.price)];
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
    return _discount + (_walletActiveForOrder ? _walletDiscount : 0);
}

- (void)setDiscount:(double)discount{
    _discount = discount;
    
    [_parentManager manager:self haveChange:DBPromoManagerChangeDiscount];
}

- (void)setShippingPrice:(double)shippingPrice{
    _shippingPrice = shippingPrice;
    
    [_parentManager manager:self haveChange:DBPromoManagerChangeShippingPrice];
}

- (BOOL)checkCurrentOrder:(void(^)(BOOL success))callback {
    if (![IHSecureStore sharedInstance].clientId) {
        return NO;
    }
    
    NSInteger currentUpdateNumber = self.lastUpdateNumber + 1;
    self.lastUpdateNumber = currentUpdateNumber;

    [DBServerAPI checkNewOrder:^(NSDictionary *response) {
        if(self.lastUpdateNumber != currentUpdateNumber){
            return;
        }
        
        // bonus points balance
        _bonusPointsBalance = [[response getValueForKey:@"full_points"] doubleValue];
//        _bonusPositionsAvailable = [[response getValueForKey:@"more_gift"] boolValue];
        _bonusPositionsAvailable = _bonusPointsBalance > 0;
        
        // Calculate discount
        double currentTotal = [OrderCoordinator sharedInstance].itemsManager.totalPrice;
        double newTotal = [response[@"total_sum"] doubleValue];
        self.discount = currentTotal - newTotal;
        
        // Calculate wallet points available for order
        self.walletDiscount = [response[@"max_wallet_payment"] doubleValue];
        
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
            
            OrderItem *orderItem = [[OrderCoordinator sharedInstance].itemsManager itemWithTemplatePosition:templatePosition];
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
        
        // Assemble order gifts
        NSMutableArray *giftItems = [NSMutableArray new];
        for(NSDictionary *giftItem in response[@"order_gifts"]){
            OrderItem *item = [OrderItem orderItemFromResponceDict:giftItem];
            item.position.mode = DBMenuPositionModeGift;
            [giftItems addObject:item];
        }
        for(NSDictionary *giftItem in response[@"new_order_gifts"]){
            OrderItem *item = [OrderItem orderItemFromResponceDict:giftItem];
            item.position.mode = DBMenuPositionModeGift;
            [giftItems addObject:item];
        }
        [[OrderCoordinator sharedInstance].orderGiftsManager overrideItems:giftItems];;
        
        _validOrder = [response[@"valid"] boolValue];
        
        if(callback)
            callback(YES);
        [_parentManager manager:self haveChange:DBPromoManagerChangeUpdatedPromoInfo];
    } failure:^(NSError *error) {
        _validOrder = NO;
        
        if(self.lastUpdateNumber == currentUpdateNumber){
            if(callback)
                callback(NO);
            [_parentManager manager:self haveChange:DBPromoManagerChangeUpdatedPromoInfo];
        }
    }];
    
    return YES;
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
            [self.parentManager manager:self haveChange:DBPromoManagerChangeWalletBalance];
            
            [self synchronize];
            
            if(callback)
                callback(self.walletBalance);
        }
    }];
}

- (void)setWalletDiscount:(double)walletPointsAvailableForOrder{
    _walletDiscount = walletPointsAvailableForOrder;
    
    [[OrderCoordinator sharedInstance] manager:self haveChange:DBPromoManagerChangeWalletDiscount];
}

- (void)setWalletActiveForOrder:(BOOL)walletActiveForOrder{
    _walletActiveForOrder = walletActiveForOrder;
    
    [[OrderCoordinator sharedInstance] manager:self haveChange:DBPromoManagerChangeWalletDiscount];
}

#pragma mark - DBManagerProtocol

- (void)flushCache{
    _shippingPrice = 0;
    self.discount = 0;
    self.walletDiscount = 0;
}

- (void)flushStoredCache{
}


#pragma mark - Helper methods

- (void)loadFromMemory{
    NSDictionary *promoInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsPromoInfo];
    
    NSDictionary *bonusPositionsPromo = promoInfo[@"bonusPositionsPromo"];
    NSData *positionsAvailableAsBonuses = bonusPositionsPromo[@"positionsAvailableAsBonuses"];
    _bonusPositionsTextDescription = bonusPositionsPromo[@"bonusPositionsTextDescription"] ?: @"";
    @try {
        _positionsAvailableAsBonuses = [NSKeyedUnarchiver unarchiveObjectWithData:positionsAvailableAsBonuses] ?: @[];
    }
    @catch (NSException *exception) {
        _positionsAvailableAsBonuses = @[];
    }
    
    
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
