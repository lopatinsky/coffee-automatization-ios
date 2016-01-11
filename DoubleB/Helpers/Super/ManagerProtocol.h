//
//  DBManagerProtocol.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 27.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ManagerProtocol <NSObject>

/**
 * Clear runtime cache
 */
- (void)flushCache;

/**
 * Clear runtime & defaults cache
 */
- (void)flushStoredCache;

@end
