//
//  DBDeliveryType.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBDeliveryType.h"

@implementation DBDeliveryType

- (instancetype)initWithResponseDict:(NSDictionary *)responseDict{
    self = [super init];
    
    _typeId = [responseDict[@"id"] intValue];
    _typeName = responseDict[@"name"];
    
    _minOrderSum = [responseDict[@"min_sum"] doubleValue];
    
    _useTimeSelection = responseDict[@"time_picker"];
    _minTimeInterval = [responseDict[@"time_picker_min"] intValue];
    _maxTimeInterval = [responseDict[@"time_picker_max"] intValue];
    
    NSMutableArray *timeSlots = [NSMutableArray new];
    for(NSDictionary *slotDict in responseDict[@"slots"]){
        [timeSlots addObject:[[DBTimeSlot alloc] initWithResponseDict:slotDict]];
    }
    _timeSlots = timeSlots;
    
    return self;
}

@end


@implementation DBTimeSlot

- (instancetype)initWithResponseDict:(NSDictionary *)responseDict{
    self = [super init];
    
    _slotId = responseDict[@"id"];
    _slotTitle = responseDict[@"name"];
    _slotDict = responseDict;
    
    return self;
}

@end