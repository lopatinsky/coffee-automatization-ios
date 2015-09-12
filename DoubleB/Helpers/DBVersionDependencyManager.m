//
//  DBVersionDependencyManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 12/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBVersionDependencyManager.h"

#import "Order.h"
#import "OrderItem.h"
#import "DBMenu.h"
#import "DBMenuPosition.h"

NSString *const kDBDefaultsVersionDependencyManager = @"kDBDefaultsVersionDependencyManager";

@implementation DBVersionDependencyManager

+ (void)performAll {
    
}

+ (void)analyzeUserModifierChoicesFromHistory {
    BOOL analyzed = [[NSUserDefaults standardUserDefaults] boolForKey:kDBDefaultsVersionDependencyManager];
    
    if(!analyzed){
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

@end
