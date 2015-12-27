//
//  NSDate+Difference.h
//  DoubleB
//
//  Created by Balaban Alexander on 16/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Difference)

- (NSInteger)numberOfDaysUntil:(NSDate *)another;
- (NSInteger)numberOfSecondsUntil:(NSDate *)another;

@end
