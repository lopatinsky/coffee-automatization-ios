//
//  ApplicationInteractionManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderWatch.h"
#import "ExtensionDelegate.h"

@interface ApplicationInteractionManager : NSObject

@property (nonatomic, weak) ExtensionDelegate *delegate;

+ (nonnull instancetype)sharedManager;

- (void)openSession;

- (void)postMessageToApplication:(nonnull NSDictionary<NSString *, id> *)msg;
- (nullable OrderWatch *)currentOrder;

- (void)saveOrder:(nonnull OrderWatch *)owatch;
- (void)cancelOrder;
- (void)makeReorder:(nonnull NSString *)newOrderId;

- (void)updateComplications;

@end
