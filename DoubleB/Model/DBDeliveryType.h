//
//  DBDeliveryType.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DeliveryTypeId) {
    DeliveryTypeIdShipping = 2,
    DeliveryTypeIdInRestaurant = 1,
    DeliveryTypeIdTakeaway = 0
};


@interface DBDeliveryType : NSObject<NSCoding>
@property (nonatomic) DeliveryTypeId typeId;
@property (strong, nonatomic) NSString *typeName;

@property (nonatomic) double minOrderSum;

@property (nonatomic) BOOL useTimeSelection;
@property (nonatomic) int minTimeInterval;
@property (nonatomic) int maxTimeInterval;

@property (strong, nonatomic) NSArray *timeSlots;

- (instancetype)initWithResponseDict:(NSDictionary *)responseDict;
@end


@interface DBTimeSlot : NSObject<NSCoding>
@property (strong, nonatomic) NSString *slotId;
@property (strong, nonatomic) NSString *slotTitle;
@property (strong, nonatomic) NSDictionary *slotDict;

- (instancetype)initWithResponseDict:(NSDictionary *)responseDict;
@end
