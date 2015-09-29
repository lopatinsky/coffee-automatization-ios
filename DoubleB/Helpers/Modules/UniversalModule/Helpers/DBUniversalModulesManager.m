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

@implementation DBUniversalModulesManager

- (instancetype)init {
    self = [super init];
    
    return self;
}

- (void)enableModule:(BOOL)enabled withDict:(NSDictionary *)moduleDict {
    if(enabled) {
        NSMutableArray *availableModules = [NSMutableArray new];
        for (NSDictionary *groupDict in moduleDict[@"groups"]) {
            NSMutableArray *items = [NSMutableArray new];
            for (NSDictionary *itemDict in groupDict[@"fields"]) {
                DBUniversalModuleItem *item = [DBUniversalModuleItem new];
                item.placeholder = [itemDict getValueForKey:@"title"] ?: @"";
                item.order = [[itemDict getValueForKey:@"order"] integerValue];
                item.jsonField = [itemDict getValueForKey:@"field"] ?: @"";
                
                [items addObject:item];
            }
            
            DBUniversalModule *module = [[DBUniversalModule alloc] initWithItems:items];
            module.title = [groupDict getValueForKey:@"group_title"] ?: @"";
            module.jsonField = [groupDict getValueForKey:@"group_field"] ?: @"";
            [availableModules addObject:module];
        }
        
        
        _availableModules = availableModules;
    } else {
        _availableModules = @[];
    }
}

@end
