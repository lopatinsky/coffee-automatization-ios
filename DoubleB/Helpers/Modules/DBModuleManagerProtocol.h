//
//  DBModuleManagerProtocol.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBModuleManagerProtocol <NSObject>

- (void)enableModule:(BOOL)enabled withDict:(NSDictionary *)moduleDict;

@end
