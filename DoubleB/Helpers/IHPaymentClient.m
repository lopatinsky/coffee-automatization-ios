//
//  IHPaymentClient.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 04.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "IHPaymentClient.h"
#import "DBAPIClient.h"

@implementation IHPaymentClient

+ (instancetype)sharedClient {
    static IHPaymentClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:[[DBAPIClient baseUrl] stringByAppendingString:@"payment/"]];
        _sharedClient = [[IHPaymentClient alloc] initWithBaseURL:baseUrl];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
        self.requestSerializer = [AFHTTPRequestSerializer serializer];    
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return self;
}

@end
