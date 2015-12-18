//
//  NetworkManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 11/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@class OrderWatch;

@interface WatchNetworkManager : NSObject

+ (void)makeReorder:(NSDictionary *)order onController:(WKInterfaceController *)controller;
+ (void)cancelOrder:(OrderWatch *)order onController:(WKInterfaceController *)controller;
+ (void)updateState:(OrderWatch *)order;

@end
