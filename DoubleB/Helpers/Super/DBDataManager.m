//
//  DBDataManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBDataManager.h"

@implementation DBDataManager

+ (NSString *)db_managerStorageKey {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

+ (id)valueForKey:(NSString *)key{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:[self db_managerStorageKey]];
    return info[key];
}

+ (void)setValue:(id)value forKey:(NSString *)key {
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:[self db_managerStorageKey]];
    NSMutableDictionary *mutableInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    
    if(value){
        mutableInfo[key] = value;
    } else {
        [mutableInfo removeObjectForKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableInfo forKey:[self db_managerStorageKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeAllValues {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self db_managerStorageKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
