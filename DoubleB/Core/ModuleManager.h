//
//  ModuleManager.h
//  
//
//  Created by Balaban Alexander on 19/08/15.
//
//

#import <Foundation/Foundation.h>

@protocol ModuleServerAPIProtocol <NSObject>

- (nonnull NSDictionary *)getOrderParams;
- (nonnull NSDictionary *)getCheckOrderParams;

@end

@interface ModuleManager : NSObject<ModuleServerAPIProtocol>

+ (nonnull instancetype)sharedManager;

- (void)addModule:(nonnull id<ModuleServerAPIProtocol>)module;
- (void)removeModule:(nonnull id<ModuleServerAPIProtocol>)module;
- (nonnull NSArray *)getModules;

- (void)cleanManager;

@end
