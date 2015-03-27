//
//  AFHTTPRequestOperationManager+TimeoutExtension.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 28.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface AFHTTPRequestOperationManager (TimeoutExtension)

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                         timeout:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
