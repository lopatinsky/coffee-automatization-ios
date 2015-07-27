//
//  DeliverySettings.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DeliverySettings.h"

NSString *const kDBDeliverySettingsNewSelectedTimeNotification = @"kDBDeliverySettingsNewSelectedTimeNotification";

@interface DeliverySettings ()
@property (strong, nonatomic) DBDeliveryType *lastNotShippingDeliveryType;

// Time management
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DeliverySettings

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DeliverySettings *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init{
    self = [super init];
    
    self.deliveryType = [[DBCompanyInfo sharedInstance].deliveryTypes firstObject];
    
    return self;
}

#pragma mark - Delivery type

- (void)selectDeliveryType:(DBDeliveryType *)type{
    if(type.typeId == DeliveryTypeIdShipping){
        self.lastNotShippingDeliveryType = self.deliveryType;
    }
    
    self.deliveryType = type;
    switch (self.deliveryType.typeId) {
        case DeliveryTypeIdInRestaurant:
            [GANHelper analyzeEvent:@"delivery_type_selected" label:@"InRestaurant" category:ADDRESS_SCREEN];
            break;
        case DeliveryTypeIdTakeaway:
            [GANHelper analyzeEvent:@"delivery_type_selected" label:@"Takeaway" category:ADDRESS_SCREEN];
            break;
        default:
            break;
    }
}

- (void)selectShipping{
    if(self.deliveryType && self.deliveryType.typeId != DeliveryTypeIdShipping)
        self.lastNotShippingDeliveryType = self.deliveryType;
    
    self.deliveryType = [[DBCompanyInfo sharedInstance] deliveryTypeById:DeliveryTypeIdShipping];
    [GANHelper analyzeEvent:@"delivery_type_selected" label:@"Shipping" category:ADDRESS_SCREEN];
}

- (void)selectTakeout{
    if(self.lastNotShippingDeliveryType)
        self.deliveryType = self.lastNotShippingDeliveryType;
}

- (void)setDeliveryType:(DBDeliveryType *)deliveryType{
    _deliveryType = deliveryType;
    
    if(_deliveryType.timeMode & (TimeModeTime | TimeModeDateTime)){
        [self launchTimer];
    } else {
        [self stopTimer];
    }
    
    [self updateTimeAccordingToDeliveryType];
}


#pragma mark - Time management

- (void)launchTimer {
    if (!self.timer) {
        long long seconds = [[NSDate date] timeIntervalSince1970];
        seconds = seconds - seconds % 60 + 60 + 1;
        self.timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSince1970:seconds] interval:15.f
                                                target:self
                                              selector:@selector(timerTick:)
                                              userInfo:nil
                                               repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        [self timerTick:self.timer];
    }
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateTimeAccordingToDeliveryType {
    if(_deliveryType.timeMode & (TimeModeTime | TimeModeDateTime | TimeModeDateSlots)){
        if(!self.selectedTime || [self.selectedTime compare:_deliveryType.minDate] == NSOrderedAscending){
            self.selectedTime = _deliveryType.minDate;
        }
        
        if([self.selectedTime compare:_deliveryType.maxDate] == NSOrderedDescending){
            self.selectedTime = _deliveryType.maxDate;
        }
    }
    
    if(self.deliveryType.timeMode & (TimeModeSlots | TimeModeDateSlots)){
        DBTimeSlot *timeSlot = [_deliveryType timeSlotWithName:self.selectedTimeSlot.slotTitle];
        if(!timeSlot)
            timeSlot = [_deliveryType.timeSlots firstObject];
        
        self.selectedTimeSlot = timeSlot;
    }
}

- (void)timerTick:(NSTimer *)timer{
    self.minimumTime = [[NSDate date] dateByAddingTimeInterval:self.deliveryType.minTimeInterval];
    [self reloadTime];
}

- (void)reloadTime{
    if(!self.selectedTime || [self.selectedTime compare:self.minimumTime] != NSOrderedDescending){
        self.selectedTime = self.minimumTime;
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBDeliverySettingsNewSelectedTimeNotification object:nil]];
    }
}

- (NSInteger)setNewSelectedTime:(NSDate *)date{
    NSInteger result;
    
    result = [date compare:self.deliveryType.minDate];
    
    if(result != NSOrderedAscending){
        result = [date compare:self.deliveryType.maxDate];
        if(result != NSOrderedDescending){
            _selectedTime = date;
            result = NSOrderedSame;
        } else {
            _selectedTime = self.deliveryType.maxDate;
        }
    } else {
        _selectedTime = self.deliveryType.minDate;
    }
    
    return result;
}

#pragma mark - DBManagerProtocol

- (void)flushCache{
}

- (void)flushStoredCache{
    [self flushCache];
}

@end
