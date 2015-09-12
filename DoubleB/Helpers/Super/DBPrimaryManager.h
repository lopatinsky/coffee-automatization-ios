//
//  DBPrimaryManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBDataManager.h"

/**
 * Superclass for all managers(first level) that manages logic of application
 */
@interface DBPrimaryManager : DBDataManager

+ (instancetype)sharedInstance;

@end

/**
 * Category for subscription on all changes inside manager
 */
@interface DBPrimaryManager (ChangesNotification)

- (void)addObserver:(NSObject * __nonnull)object withKeyPath:(NSString * __nonnull)keyName selector:(__nonnull SEL)selector;
- (void)addObserver:(NSObject * __nonnull)object withKeyPaths:(NSArray * __nonnull)keyNames selector:(__nonnull SEL)selector;

- (void)removeObserver:(NSObject * __nonnull )observer forKeyPath:(NSString * __nonnull)keyName;
- (void)removeObserver:(NSObject * __nonnull )observer;

- (void)notifyObserverOf:(NSString * __nonnull)keyName;

@end
