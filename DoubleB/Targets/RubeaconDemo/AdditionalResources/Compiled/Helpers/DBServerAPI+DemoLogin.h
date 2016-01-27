//
//  DBServerAPI+DemoLogin.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBServerAPI.h"

@class DBCompany;
@interface DBServerAPI (DemoLogin)

+ (void)demoLogin:(NSString *)login
         password:(NSString *)password
          success:(void(^)(DBCompany *company))success
          failure:(void(^)(NSString *description))failure;

@end
