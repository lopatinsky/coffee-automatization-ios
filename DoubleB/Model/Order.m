//
//  Order.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "Order.h"
#import "CoreDataHelper.h"
#import "DBAPIClient.h"
#import "Position.h"
#import "MenuHelper.h"

@implementation Order {
    NSArray *_items;
}
@dynamic orderId, total, createdAt, dataItems, status, venue, paymentType;

- (NSArray *)items {
    if (!_items) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:self.dataItems];
        /*NSMutableArray *pos = [NSMutableArray array];
        for (NSDictionary *obj in array) {
            //[pos addObject:[Position positionWithDictionary:obj]];
            Position *position = [[MenuHelper sharedHelper] findPositionWithId:obj[@"item_id"]];
            if(position && obj[@"quantity"]){
                [pos addObject: @{@"position": position,
                                  @"count": obj[@"quantity"]}];
            }
        }*/
        _items = array;
    }
    
    return _items;
}

- (instancetype)init:(BOOL)stored {
    if (stored) {
        return [self initWithEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext:[CoreDataHelper sharedHelper].context] insertIntoManagedObjectContext:[CoreDataHelper sharedHelper].context];
    } else {
        return [self initWithEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext:nil] insertIntoManagedObjectContext:nil];
    }
}

+ (void)dropOrdersHistoryIfItIsFirstLaunchOfSomeVersions{
    NSString *lastMajorUpdateVersion = @"1.2";
    
    NSString *fieldName = [NSString stringWithFormat:@"launchedBeforeVersion_%@", lastMajorUpdateVersion];
    BOOL isLaunchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:fieldName];
    
    if(!isLaunchedBefore){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fieldName];
        [Order dropAllOrders];
    }
}

+ (void)dropAllOrders{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    
    NSArray *orders = [[CoreDataHelper sharedHelper].context executeFetchRequest:request error:nil];
    
    for(Order *order in orders){
        [[CoreDataHelper sharedHelper].context deleteObject:order];
    }
}

+ (NSArray *)allOrders {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"status" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    
    NSArray *orders = [[CoreDataHelper sharedHelper].context executeFetchRequest:request error:nil];
    
    return orders;
}

+ (void)synchronizeStatusesForOrders:(NSArray *)orders withCompletionHandler:(void(^)(BOOL success, NSArray *orders))completionHandler {
    NSMutableArray *orderIds = [NSMutableArray array];
    for (Order *order in orders) {
        [orderIds addObject:order.orderId];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"orders": orderIds}
                                                       options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[DBAPIClient sharedClient] POST:@"status.php"
                          parameters:@{
                                       @"orders": jsonString
                             }
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%s %@", __PRETTY_FUNCTION__, responseObject);
                                 for (NSDictionary *status in responseObject[@"status"]) {
                                     for (Order *order in orders) {
                                         if ([status[@"order_id"] isEqualToString:order.orderId]) {
                                             order.status = ([status[@"status"] intValue]);
                                         }
                                     }
                                 }
                                 [[CoreDataHelper sharedHelper] save];
                                 if (completionHandler) {
                                     completionHandler(YES, orders);
                                 }
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
                                 if (completionHandler) {
                                     completionHandler(NO, nil);
                                 }
                             }];
}


@end
