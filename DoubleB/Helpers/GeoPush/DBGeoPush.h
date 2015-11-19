//
//  DBGeoPush.h
//  DoubleB
//
//  Created by Balaban Alexander on 28/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBGeoPush : NSObject <NSCoding>

@property (nonatomic) NSInteger orderDelayDays;
@property (nonatomic) NSInteger pushDelayDays;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) BOOL lastOrder;
@property (nonatomic) NSTimeInterval lastOrderTimestamp;
@property (nonatomic, strong) NSArray *points;

- (instancetype)initWithResponseDict:(NSDictionary *)dict;
- (BOOL)pushIsAvailable;
- (void)pushLocalNotification;

@end
