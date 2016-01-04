//
//  NSDate+Difference.m
//  DoubleB
//
//  Created by Balaban Alexander on 16/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "NSDate+Difference.h"

@implementation NSDate (Difference)

- (NSDateComponents *)getComponents:(NSDate *)another {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:another toDate:self options:NSCalendarWrapComponents];
    return components;
    
}

- (NSInteger)numberOfDaysUntil:(NSDate *)another {
    return [[self getComponents:another] day];
}

- (NSInteger)numberOfSecondsUntil:(NSDate *)another {
    return [[self getComponents:another] second];
}

@end
