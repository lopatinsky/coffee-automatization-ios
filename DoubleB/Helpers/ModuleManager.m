//
//  ModuleManager.m
//  
//
//  Created by Balaban Alexander on 19/08/15.
//
//

#import "ModuleManager.h"

@interface ModuleManager()

@property (nonatomic, strong) NSMutableArray *modules;

@end

@implementation ModuleManager

+ (instancetype)sharedManager {
    static ModuleManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ModuleManager new];
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

#pragma mark - ModuleServerAPIProtocol
- (NSDictionary *)getOrderParams {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [self.modules enumerateObjectsUsingBlock:^(id<ModuleServerAPIProtocol> obj, NSUInteger idx, BOOL *stop) {
        [params addEntriesFromDictionary:[obj getOrderParams]];
    }];
    
    return params;
}

- (NSDictionary *)getCheckOrderParams {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [self.modules enumerateObjectsUsingBlock:^(id<ModuleServerAPIProtocol> obj, NSUInteger idx, BOOL *stop) {
        [params addEntriesFromDictionary:[obj getCheckOrderParams]];
    }];
    
    return params;
}

@end
