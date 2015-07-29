//
//  OrderItem.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBMenuPosition;

typedef NS_ENUM(NSInteger, OrderItemType) {
    OrderItemTypeRegular = 0,
    OrderItemTypeBonus,
    OrderItemTypeGift
};

@interface OrderItem : NSObject <NSCoding, NSCopying>

@property (nonatomic) OrderItemType type;
@property (strong, nonatomic) DBMenuPosition *position;
@property (nonatomic, readonly) double totalPrice;
@property (nonatomic) NSInteger count;

- (instancetype)initWithPosition:(DBMenuPosition *)position;

+ (instancetype)orderItemFromHistoryDictionary:(NSDictionary *)historyItem;

@end


@interface OrderItemGift : OrderItem
@property (nonatomic) BOOL enabled;
@end