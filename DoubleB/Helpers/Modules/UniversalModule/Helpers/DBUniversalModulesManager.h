//
//  DBUniversalModulesManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"
#import "DBModuleManagerProtocol.h"

@interface DBUniversalModulesManager : DBPrimaryManager<DBModuleManagerProtocol>

@property (strong, nonatomic, readonly) NSArray *availableModules;

@end
