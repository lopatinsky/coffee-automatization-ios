//
//  DBPrimaryManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"

#import <objc/runtime.h>

static char INSTANCE_KEY;

@implementation DBPrimaryManager

+ (id)getInstance {
    return objc_getAssociatedObject(self, &INSTANCE_KEY);
}

+ (void)setInstance:(id)instance {
    objc_setAssociatedObject(self, &INSTANCE_KEY, instance, OBJC_ASSOCIATION_RETAIN);
}

+ (instancetype)sharedInstance {
    if(![self getInstance]){
        [self setInstance: [[self class] new]];
    }
    
    return [self getInstance];
}

@end

@implementation DBPrimaryManager (ChangesNotification)

- (NSString *)fullKeyName:(NSString *)key {
    return [NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), key];
}

- (void)addObserver:(NSObject *)object withKeyPath:(NSString *)keyName selector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:object selector:selector name:[self fullKeyName:keyName] object:nil];
}

- (void)addObserver:(NSObject *)object withKeyPaths:(NSArray *)keyNames selector:(SEL)selector{
    for(NSString *keyName in keyNames){
        [self addObserver:object withKeyPath:keyName selector:selector];
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyName {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:[self fullKeyName:keyName] object:nil];
}

- (void)removeObserver:(NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)notifyObserverOf:(NSString *)keyName {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[self fullKeyName:keyName] object:nil]];
}

@end
