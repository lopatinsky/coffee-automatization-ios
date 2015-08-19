//
//  ModuleManager.h
//  
//
//  Created by Balaban Alexander on 19/08/15.
//
//

#import <Foundation/Foundation.h>

@protocol ModuleServerAPIProtocol <NSObject>

- (NSDictionary *)getOrderParams;
- (NSDictionary *)getCheckOrderParams;

@end

@interface ModuleManager : NSObject<ModuleServerAPIProtocol>

+ (instancetype)sharedManager;

- (void)addModule:(id<ModuleServerAPIProtocol>)module;
- (void)removeModule:(id<ModuleServerAPIProtocol>)module;

@end
