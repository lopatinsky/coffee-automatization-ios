//
//  DBUniversalModulesManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUniversalModulesManager.h"
#import "DBUniversalModule.h"
#import "DBUniversalModuleItem.h"

#import "DBUniversalModuleDelegate.h"

@interface DBUniversalModulesManager ()<DBUniversalModuleDelegate>

@end

@implementation DBUniversalModulesManager

- (instancetype)init {
    self = [super init];
    
    NSData *modulesData = [DBUniversalModulesManager valueForKey:@"clientInfoModulesData"];
    _availableModules = [NSKeyedUnarchiver unarchiveObjectWithData:modulesData];
    for (DBUniversalModule *module in _availableModules){
        module.delegate = self;
    }
    
    return self;
}

- (void)enableModule:(BOOL)enabled withDict:(NSDictionary *)moduleDict {
    if(enabled) {
        NSMutableArray *availableModules = [NSMutableArray new];
        for (NSDictionary *groupDict in moduleDict[@"groups"]) {
            NSString *groupId = groupDict[@"group_field"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moduleId == %@", groupId];
            DBUniversalModule *module = [[_availableModules filteredArrayUsingPredicate:predicate] firstObject];
            
            if(module) {
                [module syncWithResponseDict:groupDict];
                [availableModules addObject:module];
            } else {
                DBUniversalModule *newModule = [[DBUniversalModule alloc] initWithResponseDict:groupDict];
                newModule.delegate = self;
                [availableModules addObject:newModule];
            }
        }
        _availableModules = availableModules;
    } else {
        _availableModules = @[];
    }
    
    [self save];
}

- (void)save {
    NSData *modulesData = [NSKeyedArchiver archivedDataWithRootObject:_availableModules];
    [DBUniversalModulesManager setValue:modulesData forKey:@"clientInfoModulesData"];
}

#pragma mark - DBPrimaryManager

+ (NSString *)db_managerStorageKey {
    return @"DBDefaultsUniversalModulesManager";
}

#pragma mark - DBUniversalModuleDelegate

- (void)db_universalModuleHaveChange {
    [self save];
}

@end
