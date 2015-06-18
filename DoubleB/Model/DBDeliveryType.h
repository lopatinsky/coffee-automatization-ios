//
//  DBDeliveryType.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBTimeSlot;

typedef NS_ENUM(NSUInteger, DeliveryTypeId) {
    DeliveryTypeIdShipping = 2,
    DeliveryTypeIdInRestaurant = 1,
    DeliveryTypeIdTakeaway = 0
};

typedef NS_ENUM(NSUInteger, TimeMode) {
    TimeModeTime = 1,
    TimeModeDateTime,
    TimeModeSlots,
    TimeModeDateSlots
};


@interface DBDeliveryType : NSObject<NSCoding>
@property (nonatomic) DeliveryTypeId typeId;
@property (strong, nonatomic) NSString *typeName;

@property (nonatomic) double minOrderSum;

@property (nonatomic) TimeMode timeMode;

@property (nonatomic) int minTimeInterval;
@property (nonatomic) int maxTimeInterval;

@property (strong, nonatomic, readonly) NSDate *minDate;
@property (strong, nonatomic, readonly) NSDate *maxDate;

@property (strong, nonatomic) NSArray *timeSlots;
@property (strong, nonatomic) NSArray *timeSlotsNames;

- (instancetype)initWithResponseDict:(NSDictionary *)responseDict;

- (DBTimeSlot *)timeSlotWithName:(NSString *)name;
@end


@interface DBTimeSlot : NSObject<NSCoding>
@property (strong, nonatomic) NSString *slotId;
@property (strong, nonatomic) NSString *slotTitle;
@property (strong, nonatomic) NSDictionary *slotDict;

- (instancetype)initWithResponseDict:(NSDictionary *)responseDict;
@end
