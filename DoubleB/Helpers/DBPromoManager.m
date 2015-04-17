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

@interface DBPromoManager ()
@property (strong, nonatomic) NSNumber *targetTime;

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
        self.validOrder = YES;
    }
    return self;
}

- (void)notifyTotalSumObserver:(double)total{
    if([self.updateTotalDelegate respondsToSelector:@selector(promoManager:didUpdateInfoWithTotal:)]){
        [self.updateTotalDelegate promoManager:self didUpdateInfoWithTotal:total];
    }
}

- (void)updateInfo{
    NSInteger currentUpdateNumber = self.lastUpdateNumber + 1;
    self.lastUpdateNumber = currentUpdateNumber;
    if ([IHSecureStore sharedInstance].clientId) {
        [DBServerAPI checkNewOrder:^(NSDictionary *response) {
            double total = [response[@"total_sum"] doubleValue];
            
            NSMutableArray *globalPromoMessages = [NSMutableArray new];
            NSMutableArray *globalErrorsMessages = [NSMutableArray new];
            
            for(NSString *error in response[@"errors"]){
                [globalErrorsMessages addObject:error];
            }
            
            for (NSDictionary *promo in response[@"promos"]) {
                [globalPromoMessages addObject:promo[@"text"]];
            }
            [OrderManager sharedManager].globalPromos = globalPromoMessages;
            [OrderManager sharedManager].globalErrors = globalErrorsMessages;
            
            
            NSMutableArray *itemsInfo = [[NSMutableArray alloc] init];
            for(NSDictionary *item in response[@"items"]){
                NSMutableArray *itemPromos = [NSMutableArray new];
                for(NSDictionary *itemPromo in item[@"promos"]){
                    [itemPromos addObject:itemPromo[@"text"]];
                }
                
                DBMenuPosition *templatePosition = [[[DBMenu sharedInstance] findPositionWithId:item[@"id"]] copy];
                
                for(NSDictionary *groupModifierItem in item[@"group_modifiers"]){
                    [templatePosition selectItem:groupModifierItem[@"choice"]
                                forGroupModifier:groupModifierItem[@"id"]];
                }
                
                for(NSDictionary *singleModifier in item[@"single_modifiers"]){
                    [templatePosition addSingleModifier:singleModifier[@"id"] count:[singleModifier[@"quantity"] intValue]];
                }
                
                [itemsInfo addObject:@{@"item": templatePosition,
                                       @"promos": itemPromos,
                                       @"errors": item[@"errors"]}];
            }
            
            if(self.lastUpdateNumber == currentUpdateNumber){
                [self notifyTotalSumObserver:total];
                
                if([response[@"valid"] boolValue]){
                    self.validOrder = YES;
                    
                    if([self.updateInfoDelegate respondsToSelector:@selector(promoManager:didUpdateInfo:promos:)]){
                        [self.updateInfoDelegate promoManager:self
                                                didUpdateInfo:itemsInfo
                                                   promos:globalPromoMessages];
                    }
                } else {
                    self.validOrder = NO;
                    
                    if([self.updateInfoDelegate respondsToSelector:@selector(promoManager:didUpdateInfo:errors:promos:)]){
                        [self.updateInfoDelegate promoManager:self
                                                didUpdateInfo:itemsInfo
                                                   errors:response[@"errors"]
                                                   promos:globalPromoMessages];
                    }
                }
            }
        } failure:^(NSError *error) {
            self.validOrder = NO;
            
            if(self.lastUpdateNumber == currentUpdateNumber){
                if([self.updateInfoDelegate respondsToSelector:@selector(promoManager:didFailUpdateInfoWithError:)]){
                    [self.updateInfoDelegate promoManager:self didFailUpdateInfoWithError:error];
                }
            }
        }];
    };
    
    /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        double total = 134;
        NSArray *itemsInfo = @[@{@"id": @"10", @"promos":@[@"Сегодня до 15:00 в кофейне Милютинский, 3 скидка на Аэропресс 20%", @"secondDescription"]}];
        
        for(id observer in self.updateObservers){
            if([observer respondsToSelector:@selector(promoManager:didUpdateInfo:withTotal:)]){
                [observer promoManager:self didUpdateInfo:itemsInfo withTotal:total];
            }
        }
    });*/
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
