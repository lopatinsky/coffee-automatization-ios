//
//  DBPrimaryManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"

@implementation DBPrimaryManager

+ (instancetype)sharedInstance {
    static DBPrimaryManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
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
