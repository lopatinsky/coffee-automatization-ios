//
//  NSDictionary+DeepMerge.m
//  
//
//  Created by Balaban Alexander on 19/08/15.
//
//

#import "NSDictionary+DeepMerge.h"

@implementation NSDictionary (DeepMerge)

+ (NSDictionary *)dictionaryByMerging:(NSDictionary *)dict1 with:(NSDictionary *)dict2 {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dict1];
    
    [dict2 enumerateKeysAndObjectsUsingBlock:^(id key, id obj2, BOOL *stop) {
        NSObject *obj1 = [dict1 objectForKey:key];
        if (obj1) {
            if ([obj1 isKindOfClass:[NSDictionary class]] && [obj2 isKindOfClass:[NSDictionary class]]) {
                [result setObject:[NSDictionary dictionaryByMerging:(NSDictionary *)obj1 with:obj2] forKey:key];
            } else if ([obj1 isKindOfClass:[NSArray class]] && [obj2 isKindOfClass:[NSArray class]]) {
                [result setObject:[obj2 arrayByAddingObjectsFromArray:(NSArray *)obj1] forKey:key];
            } else {
                [result setObject:@[obj1, obj2] forKey:key];
            }
        } else {
            [result setObject:obj2 forKey:key];
        }
    }];
    
    return (NSDictionary *)[result mutableCopy];
}

- (NSDictionary *)dictionaryByMergingWith:(NSDictionary *)dict {
    return [[self class] dictionaryByMerging:self with:dict];
}

@end
