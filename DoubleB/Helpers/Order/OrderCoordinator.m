//
//  Coordinator.m
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import "OrderCoordinator.h"

@implementation OrderCoordinator(EnumMap)

- (NSString * __nonnull)notificationNameByEnum:(CoordinatorEnum)en {
    return @[@"Test1", @"Test2"][en];
}

@end

@implementation OrderCoordinator

+ (instancetype)sharedInstance {
    static OrderCoordinator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OrderCoordinator alloc] init];
    });
    return instance;
}

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(CoordinatorEnum)keyName {
    
}

- (void)removeObserver:(NSObject * __nonnull)observer forKeyPath:(CoordinatorEnum)keyPath {
    
}

#pragma mark - Manager Protocol
- (void)flushCache {
    
}

- (void)flushStoredCache {
    
}

@end
