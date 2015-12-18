//
//  OrderWatch.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "OrderWatch.h"

@implementation OrderWatch

#pragma mark - WatchAppModelProtocol

- (NSDictionary *)plistRepresentation {
    NSMutableDictionary *plist = [NSMutableDictionary new];
    
    plist[@"active"] = @(self.active);
    plist[@"reordered"] = @(self.reorderedFromWatches);
    
    plist[@"orderId"] = self.orderId;
    plist[@"total"] = self.total;
    
    plist[@"status"] = @(self.status);
    plist[@"venueId"] = self.venueId;
    plist[@"venueName"] = self.venueName;
    
    plist[@"time"] = @((int)[self.time timeIntervalSince1970]);
    plist[@"creationTime"] = @((int)[self.creationTime timeIntervalSince1970]);
    
    plist[@"requestObject"] = self.requestObject;
    plist[@"delivery_slots"] = self.timeSlots;
    
    NSMutableArray *items = [NSMutableArray new];
    for (OrderItemWatch *item in self.items) {
        [items addObject:[item plistRepresentation]];
    }
    plist[@"items"] = items;
    
    return plist;
}

+ (id)createWithPlistRepresentation:(NSDictionary *)plistDict {
    OrderWatch *order = [OrderWatch new];
    
    order.active = [plistDict[@"active"] boolValue];
    order.reorderedFromWatches = [plistDict[@"reordered"] boolValue];
    
    order.orderId = plistDict[@"orderId"];
    order.total = plistDict[@"total"];
    
    order.status = [plistDict[@"status"] integerValue];
    order.venueId = plistDict[@"venueId"];
    order.venueName = plistDict[@"venueName"];
    order.requestObject = plistDict[@"requestObject"];
    order.timeSlots = plistDict[@"delivery_slots"];
    
    order.time = [NSDate dateWithTimeIntervalSince1970:[plistDict[@"time"] integerValue]];
    NSInteger creationTimeInterval = [plistDict[@"creationTime"] integerValue];
    if(creationTimeInterval > 0)
        order.creationTime = [NSDate dateWithTimeIntervalSince1970:creationTimeInterval];
    
    NSMutableArray *items = [NSMutableArray new];
    for (NSDictionary *itemDict in plistDict[@"items"]) {
        [items addObject:[OrderItemWatch createWithPlistRepresentation:itemDict]];
    }
    order.items = items;
    
    return order;
}

@end

@implementation OrderItemWatch

- (NSDictionary *)plistRepresentation {
    NSMutableDictionary *plist = [NSMutableDictionary new];
    
    plist[@"count"] = @(self.count);
    plist[@"position"] = [self.position plistRepresentation];
    
    return plist;
}

+ (id)createWithPlistRepresentation:(NSDictionary *)plistDict {
    OrderItemWatch *item = [OrderItemWatch new];
    
    item.count = [plistDict[@"count"] integerValue];
    item.position = [MenuPositionWatch createWithPlistRepresentation:plistDict[@"position"]];
    
    return item;
}

@end

@implementation MenuPositionWatch

- (NSDictionary *)plistRepresentation {
    NSMutableDictionary *plist = [NSMutableDictionary new];
    
    plist[@"positionId"] = self.positionId;
    plist[@"name"] = self.name;
    plist[@"price"] = @(self.price);
    
    return plist;
}

+ (id)createWithPlistRepresentation:(NSDictionary *)plistDict {
    MenuPositionWatch *position = [MenuPositionWatch new];
    
    position.positionId = plistDict[@"positionId"];
    position.name = plistDict[@"name"];
    position.price = [plistDict[@"price"] doubleValue];
    
    return position;
}

@end