//
//  OrderWatch.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WatchAppModelProtocol.h"

@interface MenuPositionWatch : NSObject<WatchAppModelProtocol>

@property(strong, nonatomic) NSString *positionId;
@property(strong, nonatomic) NSString *name;
@property(nonatomic) double price;

@end


@interface OrderItemWatch : NSObject<WatchAppModelProtocol>

@property (strong, nonatomic) MenuPositionWatch *position;
@property (nonatomic) NSInteger count;

@end

@interface OrderWatch : NSObject<WatchAppModelProtocol>

@property (nonatomic) BOOL active;
@property (nonatomic) BOOL reorderedFromWatches;

@property (nonatomic, strong) NSString *orderId;
@property (nonatomic) NSInteger status;

@property (nonatomic, strong) NSNumber *total;

@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSDate *creationTime;

@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *venueName;

@property (nonatomic, strong) NSMutableDictionary *requestObject;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *timeSlots;

+ (id)createWithPlistRepresentation:(NSDictionary *)plistDict;

@end
