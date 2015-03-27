//
//  ComparedItem.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Position.h"
#import "OrderItem.h"

@interface ComparedItem : NSObject
@property (nonatomic, strong) OrderItem *orderItem;
@property (nonatomic) BOOL isOnTheMenu;

+ (instancetype) comparedItem:(Position *)item isOnTheMenu:(BOOL)onTheMenu;
@end