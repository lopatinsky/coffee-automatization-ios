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
- (DBModuleType)moduleType;
@end

@implementation DBUniversalModulesManager

- (instancetype)init {
    self = [super init];
    
    NSData *modulesData = [[self class] valueForKey:@"modulesData"];
    _modules = [NSKeyedUnarchiver unarchiveObjectWithData:modulesData];
    for (DBUniversalModule *module in _modules){
        module.delegate = self;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableModule) name:kDBModulesManagerModulesLoaded object:nil];
    [self enableModule];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enableModule {
    DBModule *module = [[DBModulesManager sharedInstance] module:[self moduleType]];
    
    if(module) {
        NSMutableArray *availableModules = [NSMutableArray new];
        for (NSDictionary *groupDict in module.info[@"groups"]) {
            NSString *groupId = groupDict[@"group_field"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moduleId == %@", groupId];
            DBUniversalModule *module = [[_modules filteredArrayUsingPredicate:predicate] firstObject];
            
            if(module) {
                [module syncWithResponseDict:groupDict];
                [availableModules addObject:module];
            } else {
                DBUniversalModule *newModule = [[DBUniversalModule alloc] initWithResponseDict:groupDict];
                newModule.delegate = self;
                [availableModules addObject:newModule];
            }
        }
        _modules = availableModules;
    } else {
        _modules = @[];
    }
    
    [self save];
}

- (DBModuleType)moduleType {
    return DBModuleTypeOrderScreenUniversal;
}

- (void)save {
    NSData *modulesData = [NSKeyedArchiver archivedDataWithRootObject:_modules];
    [[self class] setValue:modulesData forKey:@"modulesData"];
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

@implementation DBUniversalProfileModulesManager

- (DBModuleType)moduleType {
    return DBModuleTypeProfileScreenUniversal;
}

+ (NSString *)db_managerStorageKey {
    return @"DBDefaultsProfleUniversalModulesManager";
}

@end

@implementation DBUniversalOrderModulesManager

- (DBModuleType)moduleType {
    return DBModuleTypeOrderScreenUniversal;
}

+ (NSString *)db_managerStorageKey {
    return @"DBDefaultsOrderUniversalModulesManager";
}

@end
