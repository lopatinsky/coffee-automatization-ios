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

@implementation DBVersionDependencyManager

+ (void)performAll {
    [self analyzeUserModifierChoicesFromHistory];
}

+ (void)analyzeUserModifierChoicesFromHistory {
    BOOL analyzed = [self valueForKey:@"kDBUserHistoryAnalyzedForModifiers"];
    
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
    NSMutableArray *history = [[NSMutableArray alloc] initWithArray:orders];
    
    [history sortUsingComparator:^NSComparisonResult(Order *obj1, Order *obj2) {
        return [obj1.time compare:obj2.time];
    }];
    
    for (Order *order in [history reverseObjectEnumerator]){
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

#pragma mark - DBDataManager

+ (NSString *)db_managerStorageKey {
    return @"kDBDefaultsVersionDependencyManager";
}

@end
