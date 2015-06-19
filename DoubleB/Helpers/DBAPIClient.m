//
// Created by Sergey Pronin on 9/23/13.
// Copyright (c) 2013 Empatika. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DBAPIClient.h"
#import "DBCompanyInfo.h"

@interface DBAPIClient()

@property (strong, nonatomic) AFHTTPRequestSerializer *reqSerializer;

@end

@implementation DBAPIClient

+ (instancetype)sharedClient {
    static DBAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[DBAPIClient baseUrl]]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        self.reqSerializer = [AFHTTPRequestSerializer serializer];
        [self.reqSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.reqSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [self setRequestSerializer:self.reqSerializer];
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
    }
    return self;
}

+ (nullable NSString *)baseUrl {
    return [[DBCompanyInfo db_companyBaseUrl] stringByAppendingString:@"api/"];
}

- (void)setValue:(nonnull NSString *)value forHeader:(nonnull NSString *)header {
    if (self.reqSerializer) {
        [self.reqSerializer setValue:value forHTTPHeaderField:header];
    }
}

@end