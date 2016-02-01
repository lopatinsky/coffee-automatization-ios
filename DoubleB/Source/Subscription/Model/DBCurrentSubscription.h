//
//  DBCurrentSubscription.h
//  DoubleB
//
//  Created by Balaban Alexander on 21/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBCurrentSubscription : NSObject<NSCoding>

@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSNumber *days;

- (void)calculateDays;

@end
