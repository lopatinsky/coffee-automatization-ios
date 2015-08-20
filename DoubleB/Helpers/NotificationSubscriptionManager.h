//
//  NotificationSubscriptionManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationSubscriptionManager : NSObject

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(NSString * __nonnull)keyName selector:(__nonnull SEL)selector;
- (void)addObserver:(NSObject * __nonnull)object withKeyPaths:(NSArray * __nonnull)keyNames selector:(__nonnull SEL)selector;

- (void)removeObserver:(NSObject * __nonnull )observer forKeyPath:(NSString * __nonnull)keyName;
- (void)removeObserver:(NSObject * __nonnull )observer;

- (void)notifyObserverOf:(NSString * __nonnull)keyPath;

@end
