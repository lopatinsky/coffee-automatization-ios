//
// Created by Sergey Pronin on 9/23/13.
// Copyright (c) 2013 Empatika. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DBAPIClient.h"
#import "DBCompanyInfo.h"

@implementation DBAPIClient {

}

+ (instancetype)sharedClient {
    static DBAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[DBCompanyInfo db_companyBaseUrl]]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //compression
    [requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [self setRequestSerializer:requestSerializer];
    
    [self setResponseSerializer:[AFJSONResponseSerializer serializer]];

    return self;
}

@end