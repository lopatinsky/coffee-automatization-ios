//
//  NSDate+Difference.m
//  DoubleB
//
//  Created by Balaban Alexander on 16/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "NSDate+Difference.h"

@implementation NSDate (Difference)

- (NSInteger)numberOfDaysUntil:(NSDate *)another {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:another toDate:self options:NSCalendarWrapComponents];
    return [components day];
}

- (NSInteger)numberOfSecondsUntil:(NSDate *)another {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:another toDate:self options:NSCalendarWrapComponents];
    return [components second];
}

@end
