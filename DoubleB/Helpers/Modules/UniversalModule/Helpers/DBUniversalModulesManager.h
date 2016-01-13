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
/**
 * All universal modules
 */
@property (strong, nonatomic, readonly) NSArray *modules;
@end

@interface DBUniversalProfileModulesManager : DBUniversalModulesManager
@end

@interface DBUniversalOrderModulesManager : DBUniversalModulesManager
@end
