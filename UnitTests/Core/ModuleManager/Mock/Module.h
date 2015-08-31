//
//  Module.h
//  
//
//  Created by Balaban Alexander on 19/08/15.
//
//

#import <Foundation/Foundation.h>
#import "ModuleManager.h"

@interface Module : NSObject<ModuleServerAPIProtocol>

- (instancetype)initWithOrderDict:(NSDictionary *)orderDict andCheckOrderDict:(NSDictionary *)checkOrderDict;

@end
