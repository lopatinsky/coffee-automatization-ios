//
//  WatchInteractionManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 22/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"

@interface WatchInteractionManager : DBPrimaryManager

- (void)updateLastOrActiveOrder;
- (void)continueUserActivity:(nonnull NSUserActivity *)activity;

@end
