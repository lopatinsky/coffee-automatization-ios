//
//  ComparedItem.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "ComparedItem.h"
#import "OrderItem.h"

@interface ComparedItem()

@end

@implementation ComparedItem
+ (instancetype) comparedItem:(OrderItem *)item isOnTheMenu:(BOOL)onTheMenu {
    ComparedItem *comparedItem = [ComparedItem new];
    comparedItem.orderItem = item;
    comparedItem.isOnTheMenu = onTheMenu;
    
    return comparedItem;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [ComparedItem new];
    if (self != nil) {
        self.orderItem = [aDecoder decodeObjectForKey:@"orderItem"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.orderItem forKey:@"orderItem"];
}
@end