//
//  DBCustomViewManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBModuleManagerProtocol.h"

@interface DBCustomViewManager: DBPrimaryManager <DBModuleManagerProtocol>

- (BOOL)available;
- (NSArray *)items;

@end
