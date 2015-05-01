//
//  OrderItem.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBMenuPosition;

@interface OrderItem : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) DBMenuPosition *position;
@property (nonatomic, readonly) double totalPrice;
@property (nonatomic) NSInteger count;

- (instancetype)initWithPosition:(DBMenuPosition *)position;

+ (instancetype)orderItemFromHistoryDictionary:(NSDictionary *)historyItem;

@end
