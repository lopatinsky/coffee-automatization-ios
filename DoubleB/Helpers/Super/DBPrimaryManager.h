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

- (void)addObserver:(NSObject *)object withKeyPath:(NSString *)keyName selector:(SEL)selector;
- (void)addObserver:(NSObject *)object withKeyPaths:(NSArray *)keyNames selector:(SEL)selector;

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyName;
- (void)removeObserver:(NSObject *)observer;

- (void)notifyObserverOf:(NSString *)keyName;

@end
