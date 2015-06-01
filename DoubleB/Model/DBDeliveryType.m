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
    
    _minTimeInterval = [[responseDict getValueForKey:@"time_picker_min"] intValue];
    _maxTimeInterval = [[responseDict getValueForKey:@"time_picker_max"] intValue];
    
    NSMutableArray *timeSlots = [NSMutableArray new];
    for(NSDictionary *slotDict in responseDict[@"slots"]){
        [timeSlots addObject:[[DBTimeSlot alloc] initWithResponseDict:slotDict]];
    }
    _timeSlots = timeSlots;
    
    return self;
}

- (BOOL)useTimePicker{
    return [_timeSlots count] == 0;
}

- (NSArray *)timeSlotsNames{
    NSMutableArray *names = [NSMutableArray new];
    
    for(DBTimeSlot *timeSlot in _timeSlots){
        [names addObject:timeSlot.slotTitle];
    }
    
    return names;
}

- (NSDate *)minDate{
    long long seconds = [[NSDate date] timeIntervalSince1970];
    seconds = seconds - seconds % 60 + _minTimeInterval;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

- (NSDate *)maxDate{
    long long seconds = [[NSDate date] timeIntervalSince1970];
    seconds = seconds - seconds % (60*60*24) + _maxTimeInterval;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

- (BOOL)onlyTime{
    return self.maxTimeInterval <= 60*60*24;
}

- (DBTimeSlot *)timeSlotWithName:(NSString *)name{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"slotTitle == %@", name];
    
    return [[_timeSlots filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBDeliveryType alloc] init];
    if(self != nil){
        _typeId = [[aDecoder decodeObjectForKey:@"_typeId"] intValue];
        _typeName = [aDecoder decodeObjectForKey:@"_typeName"];
        
        _minOrderSum = [[aDecoder decodeObjectForKey:@"_minOrderSum"] doubleValue];
        
        _minTimeInterval = [[aDecoder decodeObjectForKey:@"_minTimeInterval"] doubleValue];
        _maxTimeInterval = [[aDecoder decodeObjectForKey:@"_maxTimeInterval"] doubleValue];
        
        _timeSlots = [aDecoder decodeObjectForKey:@"_timeSlots"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(_typeId) forKey:@"_typeId"];
    [aCoder encodeObject:_typeName forKey:@"_typeName"];
    
    [aCoder encodeObject:@(_minOrderSum) forKey:@"_minOrderSum"];
    
    [aCoder encodeObject:@(_minTimeInterval) forKey:@"_minTimeInterval"];
    [aCoder encodeObject:@(_maxTimeInterval) forKey:@"_maxTimeInterval"];
    
    [aCoder encodeObject:_timeSlots forKey:@"_timeSlots"];
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

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBTimeSlot alloc] init];
    if(self != nil){
        _slotId = [aDecoder decodeObjectForKey:@"_slotId"];
        _slotTitle = [aDecoder decodeObjectForKey:@"_slotTitle"];
        _slotDict = [aDecoder decodeObjectForKey:@"_slotDict"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_slotId forKey:@"_slotId"];
    [aCoder encodeObject:_slotTitle forKey:@"_slotTitle"];
    [aCoder encodeObject:_slotDict forKey:@"_slotDict"];
}

@end