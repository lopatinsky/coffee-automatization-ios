//
//  DBVersionDependencyManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 12/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBDataManager.h"

@interface DBVersionDependencyManager : DBDataManager

+ (void)performAll;

// Analyze user history to fetch previously selected modifiers
+ (void)analyzeUserModifierChoicesFromHistory;

// Check if it is necessary to clean app cache
+ (void)checkCompatibilityOfStoredData;

@end

