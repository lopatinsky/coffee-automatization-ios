//
//  DBServerAPI+DemoLogin.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBServerAPI+DemoLogin.h"
#import "DBAPIClient.h"

@implementation DBServerAPI (DemoLogin)

+ (void)demoLogin:(NSString *)login
         password:(NSString *)password
         callback:(void(^)(BOOL success, NSString *result))callback{
    [[DBAPIClient sharedClient] POST:@"demo/login"
                          parameters:@{@"login": login,
                                       @"password": password}
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 BOOL success = [responseObject[@"success"] boolValue];
                                 if(callback){
                                     if(success)
                                         callback(YES, responseObject[@"namespace"]);
                                     else
                                         callback(NO, responseObject[@"description"]);
                                 }
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 if(callback)
                                     callback(NO, nil);
                             }];
}

@end
