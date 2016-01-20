//
//  DBServerAPI+DemoLogin.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBServerAPI+DemoLogin.h"
#import "DBAPIClient.h"
#import "DBCompaniesManager.h"

@implementation DBServerAPI (DemoLogin)

+ (void)demoLogin:(NSString *)login
         password:(NSString *)password
         success:(void(^)(DBCompany *company))success
         failure:(void(^)(NSString *description))failure{
    [[DBAPIClient sharedClient] POST:@"demo/login"
                          parameters:@{@"login": login,
                                       @"password": password}
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 BOOL successReq = [responseObject[@"success"] boolValue];
                                 
                                 if(successReq) {
                                     DBCompany *company = [[DBCompany alloc] initWithResponseDict:responseObject];
                                     if (success)
                                         success(company);
                                 } else {
                                     if (failure)
                                         failure(responseObject[@"description"]);
                                 }
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 if(failure)
                                     failure(nil);
                             }];
}

@end
