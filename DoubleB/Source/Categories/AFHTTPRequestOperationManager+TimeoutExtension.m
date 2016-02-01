//
//  AFHTTPRequestOperationManager+TimeoutExtension.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 28.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "AFHTTPRequestOperationManager+TimeoutExtension.h"

@implementation AFHTTPRequestOperationManager (TimeoutExtension)

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                         timeout:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

@end
