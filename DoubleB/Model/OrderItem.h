//
//  OrderItem.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Position;
@class MenuPositionExtension;

@interface OrderItem : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) Position *position;
@property (strong, nonatomic) MenuPositionExtension *selectedExt;
@property (nonatomic, readonly) double totalPrice;
@property (nonatomic) NSInteger count;

@property (strong, nonatomic) NSArray *notes;
@property (strong, nonatomic) NSArray *errors;

- (instancetype)initWithPosition:(Position *)position;
- (instancetype)initWithPosition:(Position *)position extension:(MenuPositionExtension *)ext;

+ (instancetype)orderItemFromHistoryDictionary:(NSDictionary *)historyItem;

- (void)clearAdditionalInfo;
- (BOOL)shouldShowAdditionalInfo;
- (NSArray *)messages;

@end
