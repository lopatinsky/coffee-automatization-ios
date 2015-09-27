//
//  OrderPartManagerProtocol.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 28.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OrderPartManagerProtocol;

@protocol OrderParentManagerProtocol <NSObject>

- (void)manager:(id<OrderPartManagerProtocol>)manager haveChange:(NSInteger)changeType;

@end

@protocol OrderPartManagerProtocol <NSObject>

/**
 * Initializer for all managers, that manages by coordinator
 */
- (instancetype)initWithParentManager:(id<OrderParentManagerProtocol>)parentManager;

@end
