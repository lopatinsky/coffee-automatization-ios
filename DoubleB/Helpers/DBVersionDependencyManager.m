//
//  DBVersionDependencyManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 12/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBVersionDependencyManager.h"

#import "DBServerAPI.h"
#import "Order.h"
#import "OrderItem.h"
#import "DBMenu.h"
#import "DBMenuPosition.h"

#import "DBCompanyInfo.h"
#import "IHSecureStore.h"
#import "DBCardsManager.h"

@implementation DBVersionDependencyManager

+ (void)performAll {
    [self checkCompatibilityOfStoredData];
}

#pragma mark - Analyze user history
+ (void)analyzeUserModifierChoicesFromHistory {
    BOOL analyzed = [[self valueForKey:@"kDBUserHistoryAnalyzedForModifiers"] boolValue];
    
    if(!analyzed){
        NSArray *history = [Order allOrders];
        if(history.count == 0){
            [DBServerAPI fetchOrdersHistory:^(BOOL success, NSError *error) {
                if(success){
                    [self analyzeOrders:[Order allOrders]];
                    [self setValue:@(YES) forKey:@"kDBUserHistoryAnalyzedForModifiers"];
                }
            }];
        } else {
            [self analyzeOrders:history];
            [self setValue:@(YES) forKey:@"kDBUserHistoryAnalyzedForModifiers"];
        }
    }
}

+ (void)analyzeOrders:(NSArray *)orders {
    for (Order *order in orders){
        NSArray *items = order.items;
        for (OrderItem *orderItem in items){
            DBMenuPosition *samePosition = [[DBMenu sharedInstance] findPositionWithId:orderItem.position.positionId];
            if(samePosition && samePosition.hasEmptyRequiredModifiers){
                [samePosition syncWithPosition:orderItem.position];
            }
        }
    }
    
    [[DBMenu sharedInstance] saveMenuToDeviceMemory];
}

#pragma mark - check compatibility of stored data
+ (void)checkCompatibilityOfStoredData {
    if ([self needsToFlush]) {
        
        DBCardsManager *cardsManager = [DBCardsManager sharedInstance];
        [cardsManager fetchWithOldFormat];
        
        NSData *clientIdData = [[IHSecureStore sharedInstance] dataForKey:@"clientId"];
        [[IHSecureStore sharedInstance] setData:clientIdData forKey:@"iikoClientId"];
        [[IHSecureStore sharedInstance] removeForKey:@"clientId"];
        
        // Clear UserDefaults
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary * dict = [userDefaults dictionaryRepresentation];
        for (id key in dict) {
            [userDefaults removeObjectForKey:key];
        }
        [userDefaults synchronize];
        
        // Clear menu
        [[DBMenu sharedInstance] clearMenu];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@(YES)];
        [[IHSecureStore sharedInstance] setData:data forKey:@"kDBVersionDependencyManagerRemovedIIkoCache"];
    }
}

+ (BOOL)needsToFlush {
    BOOL needsToFlush = NO;
    
    if ([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"tukano"]){
        NSData *data = [[IHSecureStore sharedInstance] dataForKey:@"kDBVersionDependencyManagerRemovedIIkoCache"];
        BOOL removed = [((NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:data]) boolValue];
        if (!removed) {
            needsToFlush = YES;
        }
    }

    if ([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"iikohack"]){
        NSData *data = [[IHSecureStore sharedInstance] dataForKey:@"kDBVersionDependencyManagerRemovedIIkoCache"];
        BOOL removed = [((NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:data]) boolValue];
        if (!removed) {
            needsToFlush = YES;
        }
    }
    
    return needsToFlush;
}

#pragma mark - DBDataManager

+ (NSString *)db_managerStorageKey {
    return @"kDBDefaultsVersionDependencyManager";
}

@end
