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
    [self syncVersionsHistory];
    
    if ([self appFromIIko]) {
        [[IHSecureStore sharedInstance] migrateIIkoFlagAutomationRelease112];
        [self checkCompatibilityOfStoredData];
        [[IHSecureStore sharedInstance] migrateDataAutomationRelease112];
    } else {
        [[IHSecureStore sharedInstance] migrateDataAutomationRelease112];
    }
}

+ (void)syncVersionsHistory {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSArray *versionsArray = [DBVersionDependencyManager valueForKey:@"dbVersionHistory"];
    NSMutableArray *versions = versionsArray ? [NSMutableArray arrayWithArray:versionsArray] : [NSMutableArray new];
    if (![versions containsObject:version]) {
        [versions addObject:version];
        [DBVersionDependencyManager setValue:versions forKey:@"dbVersionHistory"];
    }
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
        
        [[IHSecureStore sharedInstance] migrateIIkoData];
        
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
    
    if ([self appFromIIko]){
        NSData *data = [[IHSecureStore sharedInstance] dataForKey:@"kDBVersionDependencyManagerRemovedIIkoCache"];
        BOOL removed = [((NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:data]) boolValue];
        if (!removed) {
            needsToFlush = YES;
        }
    }
    
    return needsToFlush;
}

+ (BOOL)appFromIIko {
    NSArray *appsToClearCache = @[@"tukano", @"sushilar", @"iikohack", @"mivako", @"omnomnom", @"orangeexpress", @"dimash", @"panda", @"burgerclub", @"sushitime"];
    
    return [appsToClearCache containsObject:[ApplicationConfig db_bundleName].lowercaseString];
}

#pragma mark - DBDataManager

+ (NSString *)db_managerStorageKey {
    return @"kDBDefaultsVersionDependencyManager";
}

@end
