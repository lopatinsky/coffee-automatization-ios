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

+ (void)analyzeUserModifierChoicesFromHistory;

@end
