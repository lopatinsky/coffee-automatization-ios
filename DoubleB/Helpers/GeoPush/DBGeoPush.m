//
//  DBGeoPush.m
//  DoubleB
//
//  Created by Balaban Alexander on 28/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBGeoPush.h"

@implementation DBGeoPush

- (instancetype)initWithResponseDict:(NSDictionary *)dict {
    self = [super init];
    
    self.orderDelayDays = [dict getIntForKey:@"days_without_order"] ?: 0;
    self.pushDelayDays = [dict getIntForKey:@"days_without_push"] ?: 0;
    self.title = [dict getValueForKey:@"head"] ?: @"";
    self.lastOrder = [[dict getValueForKey:@"last_order"] boolValue];
    self.lastOrderTimestamp = [dict getIntForKey:@"last_order_timestamp"];
    self.text = [dict getValueForKey:@"text"] ?: @"";
    self.points = [dict getValueForKey:@"points"] ?: @[];
    
    return self;
}

- (NSInteger)numberOfDaysAfterLastOrder {
    return [DBGeoPush daysBetweenDate:[NSDate date] andDate:[NSDate dateWithTimeIntervalSince1970:self.lastOrderTimestamp]];
}

- (BOOL)pushIsAvailable {
    BOOL available = YES;
    available = self.lastOrder;
    
    if (available) {
        NSDate *lastPushDate = [NSDate dateWithTimeIntervalSince1970:[[[NSUserDefaults standardUserDefaults] objectForKey:@"kDBGeoPushLastTimestamp"] floatValue]];
        available = [DBGeoPush daysBetweenDate:[NSDate date] andDate:[NSDate dateWithTimeIntervalSince1970:self.lastOrderTimestamp]] >= self.orderDelayDays &&
                    [DBGeoPush daysBetweenDate:[NSDate date] andDate:lastPushDate] >= self.pushDelayDays;
    }
    
    return available;
}

- (void)debug_pushLocalNotification:(NSInteger)seconds {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertTitle = @"debug title";
    notification.alertBody = @"debug body";
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = @{@"type": @"geopush"};
    
    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:seconds];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)pushLocalNotification {
    [[NSUserDefaults standardUserDefaults] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:@"kDBGeoPushLastTimestamp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertTitle = self.title;
    notification.alertBody = self.text;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = @{@"type": @"geopush"};
    
    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<DBGeoPush>: OrderDelayDays: %ld, PushDelayDays: %ld, Title: %@, Text: %@, Points count: %lu",
            self.orderDelayDays, self.pushDelayDays, self.title, self.text, (unsigned long)[self.points count]];
}

// TODO: remove it after merge with iOS9
+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:toDateTime];
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[DBGeoPush alloc] init];
    if (self) {
        _orderDelayDays = [[aDecoder decodeObjectForKey:@"__orderDelayDays"] integerValue];
        _pushDelayDays = [[aDecoder decodeObjectForKey:@"__pushDelayDays"] integerValue];
        _title = [aDecoder decodeObjectForKey:@"__title"];
        _lastOrder = [[aDecoder decodeObjectForKey:@"__lastOrder"] boolValue];
        _lastOrderTimestamp = [[aDecoder decodeObjectForKey:@"__lastOrderTimestamp"] boolValue];
        _text = [aDecoder decodeObjectForKey:@"__text"];
        _points = [aDecoder decodeObjectForKey:@"__points"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_orderDelayDays) forKey:@"__orderDelayDays"];
    [aCoder encodeObject:@(_pushDelayDays) forKey:@"__pushDelayDays"];
    [aCoder encodeObject:_title forKey:@"__title"];
    [aCoder encodeObject:@(_lastOrder) forKey:@"__lastOrder"];
    [aCoder encodeObject:@(_lastOrderTimestamp) forKey:@"__lastOrderTimestamp"];
    [aCoder encodeObject:_text forKey:@"__text"];
    [aCoder encodeObject:_points forKey:@"__points"];
}

@end
