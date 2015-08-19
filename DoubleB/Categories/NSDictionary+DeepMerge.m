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
    
    [dict2 enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![dict1 objectForKey:key]) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *newVal = [[dict1 objectForKey:key] dictionaryByMergingWith:(NSDictionary *)obj];
                [result setObject:newVal forKey:key];
            } else {
                [result setObject:obj forKey:key];
            }
        }
    }];
    
    return (NSDictionary *)[result mutableCopy];
}

- (NSDictionary *)dictionaryByMergingWith:(NSDictionary *)dict {
    return [[self class] dictionaryByMerging:self with:dict];
}

@end
