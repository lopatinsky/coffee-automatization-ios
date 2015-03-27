//
//  ErrorHelper.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "ErrorHelper.h"
#import "OrderManager.h"
#import "MenuHelper.h"
#import "Venue.h"
#import "ComparedItem.h"
#import "DBMenuCategory.h"
#import "DBOrderItemCell.h"
#import "OrderItem.h"
#import "MenuPositionExtension.h"

@implementation ErrorHelper

+ (instancetype) sharedHelper {
    static dispatch_once_t once;
    static ErrorHelper *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void) setErrorsWithErrors:(NSArray *)errors {
    NSMutableArray *comparedItems = [NSMutableArray new];
    for (OrderItem *item in [OrderManager sharedManager].positions) {
        [comparedItems addObject:item];
    }
    comparedItems = [self compareItemsForCurrentVenueWithItems:comparedItems];
    for (OrderItem *item in [OrderManager sharedManager].positions) {
        item.errors = @[];
        for (ComparedItem *comparedItem in comparedItems) {
            if (item.selectedExt.extId) {
                if([item.selectedExt.extId isEqualToString:comparedItem.orderItem.selectedExt.extId] && !comparedItem.isOnTheMenu) {
                    item.errors = errors;
                }
            } else {
                if ([item.position.positionId isEqualToString:comparedItem.orderItem.position.positionId] && !comparedItem.isOnTheMenu) {
                    item.errors = errors;
                }
            }
        }
    }
}

- (NSMutableArray *) compareItemsForCurrentVenueWithItems:(NSArray *)items {
    NSArray *currentMenu = [MenuHelper sharedHelper].fetchedMenu;
    NSMutableArray *comparedItems = [NSMutableArray new];
    NSMutableArray *extsIds = [NSMutableArray new];
    
    for (OrderItem *item in items) {
        ComparedItem *comparedItem = [ComparedItem new];
        comparedItem.orderItem = item;
        comparedItem.isOnTheMenu = NO;
        [comparedItems addObject:comparedItem];
    }
    
    for (DBMenuCategory *category in currentMenu) {
        for (Position *position in category.items) {
            if ([position.exts count] > 0) {
                for (MenuPositionExtension *ext in position.exts) {
                    [extsIds addObject:ext.extId];
                }
            } else {
                [extsIds addObject:position.positionId];
            }
        }
    }
    
    for (ComparedItem *item in comparedItems) {
        for (NSString *extId in extsIds) {
            if (item.orderItem.selectedExt.extId) {
                if ([item.orderItem.selectedExt.extId isEqualToString:extId]) {
                    item.isOnTheMenu = YES;
                    break;
                }
            } else {
                if ([item.orderItem.position.positionId isEqualToString:extId]){
                    item.isOnTheMenu = YES;
                    break;
                }
            }
        }
    }
    
//    for (ComparedItem *comparedItem in comparedItems) {
//        NSLog(@"PositionId: %@, isOnTheMenu: %d", comparedItem.orderItem.position.positionId, comparedItem.isOnTheMenu);
//    }
    
    return comparedItems;
}
@end