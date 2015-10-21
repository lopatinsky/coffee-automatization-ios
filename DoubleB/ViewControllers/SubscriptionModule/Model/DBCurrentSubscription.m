//
//  DBCurrentSubscription.m
//  DoubleB
//
//  Created by Balaban Alexander on 21/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCurrentSubscription.h"

@implementation DBCurrentSubscription

- (void)calculateDays {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:[NSDate dateWithTimeIntervalSinceNow:[self.days integerValue] * 24 * 60 * 60]];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:[NSDate date]];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    self.days = @([difference day]);
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBCurrentSubscription alloc] init];
    if (self != nil) {
        _amount = [aDecoder decodeObjectForKey:@"amount"];
        _creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
        _days = [aDecoder decodeObjectForKey:@"days"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_amount forKey:@"amount"];
    [aCoder encodeObject:_days forKey:@"days"];
    [aCoder encodeObject:_creationDate forKey:@"creationDate"];
}

@end
