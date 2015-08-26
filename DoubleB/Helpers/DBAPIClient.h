//
// Created by Sergey Pronin on 9/23/13.
// Copyright (c) 2013 Empatika. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager+TimeoutExtension.h"

@interface DBAPIClient : AFHTTPRequestOperationManager

+ (nullable instancetype)sharedClient;
+ (nullable NSString *)baseUrl;

- (void)setValue:(nonnull NSString *)value forHeader:(nonnull NSString *)header;
- (void)disableHeader:(nonnull NSString *)header;

@property(nonatomic) BOOL companyHeaderEnabled;
@property(nonatomic) BOOL clientHeaderEnabled;

@end