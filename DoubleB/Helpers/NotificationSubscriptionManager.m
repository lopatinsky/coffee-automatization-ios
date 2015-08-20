//
//  NotificationSubscriptionManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "NotificationSubscriptionManager.h"

@implementation NotificationSubscriptionManager

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(NSString * __nonnull)keyName selector:(__nonnull SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:object selector:selector name:keyName object:nil];
}

- (void)addObserver:(NSObject * __nonnull)object withKeyPaths:(NSArray * __nonnull)keyNames selector:(__nonnull SEL)selector{
    for(NSString *keyName in keyNames){
        [self addObserver:object withKeyPath:keyName selector:selector];
    }
}

- (void)removeObserver:(NSObject * __nonnull )observer forKeyPath:(NSString * __nonnull)keyName {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:keyName object:nil];
}

- (void)removeObserver:(NSObject * __nonnull)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)notifyObserverOf:(NSString * __nonnull)keyPath {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:keyPath object:nil]];
}

@end
