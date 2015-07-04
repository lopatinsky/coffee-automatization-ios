//
//  DBServerAPI+DemoLogin.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBServerAPI.h"

@interface DBServerAPI (DemoLogin)

+ (void)demoLogin:(NSString *)login
         password:(NSString *)password
         callback:(void(^)(BOOL success, NSString *result))callback;

@end
