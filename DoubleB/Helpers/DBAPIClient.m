//
// Created by Sergey Pronin on 9/23/13.
// Copyright (c) 2013 Empatika. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DBAPIClient.h"
#import "DBCompanyInfo.h"

NSString *const kDBDefaultsCompanyNamespaceHeader = @"kDBCompanyNamespaceHeader";

@interface DBAPIClient ()
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
    
    NSString *companyNamespace = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsCompanyNamespaceHeader];
    if(companyNamespace.length > 0){
        if (self.reqSerializer) {
            [self.reqSerializer setValue:companyNamespace forHTTPHeaderField:@"namespace"];
        }
    }

    return self;
}

+ (NSString *)baseUrl{
    return [[DBCompanyInfo db_companyBaseUrl] stringByAppendingString:@"api/"];
}

- (void)enableCompanyHeader:(NSString *)companyHeader {
    if (self.reqSerializer) {
        [self.reqSerializer setValue:companyHeader forHTTPHeaderField:@"namespace"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:companyHeader ?: @"" forKey:kDBDefaultsCompanyNamespaceHeader];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)disableCompanyHeader {
    if (self.reqSerializer) {
        [self.reqSerializer setValue:nil forHTTPHeaderField:@"namespace"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kDBDefaultsCompanyNamespaceHeader];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end