//
//  ModuleManager.m
//  
//
//  Created by Balaban Alexander on 19/08/15.
//
//

#import "ModuleManager.h"

#import "NSDictionary+DeepMerge.h"

@interface ModuleManager()

@property (nonatomic, strong) NSMutableArray *modules;

@end

@implementation ModuleManager

+ (instancetype)sharedManager {
    static ModuleManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ModuleManager new];
        instance.modules = [NSMutableArray new];
    });
    return instance;
}

- (void)addModule:(id<ModuleServerAPIProtocol>)module {
    if (![self.modules containsObject:module]) {
        [self.modules addObject:module];
    }
}

- (void)removeModule:(id<ModuleServerAPIProtocol>)module {
    [self.modules removeObject:module];
}

- (NSArray *)getModules {
    return [self.modules copy];
}

- (void)cleanManager {
    [self.modules removeAllObjects];
}

#pragma mark - ModuleServerAPIProtocol
- (NSDictionary *)getOrderParams {
    __block NSDictionary *params = [NSMutableDictionary new];
    
    [self.modules enumerateObjectsUsingBlock:^(id<ModuleServerAPIProtocol> obj, NSUInteger idx, BOOL *stop) {
        params = [params dictionaryByMergingWith:[obj getOrderParams]];
    }];
    
    return params;
}

- (NSDictionary *)getCheckOrderParams {
    __block NSDictionary *params = [NSMutableDictionary new];
    
    [self.modules enumerateObjectsUsingBlock:^(id<ModuleServerAPIProtocol> obj, NSUInteger idx, BOOL *stop) {
        params = [params dictionaryByMergingWith:[obj getCheckOrderParams]];
    }];
    
    return params;
}

@end
