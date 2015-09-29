//
//  DBModulesManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBModulesManager : NSObject

+ (instancetype)sharedInstance;

- (void)fetchModules:(void(^)(BOOL success))callback;

@end
