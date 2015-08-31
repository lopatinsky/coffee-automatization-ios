//
// Created by Sergey Pronin on 9/23/13.
// Copyright (c) 2013 Empatika. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DBAPIClient.h"
#import "IHSecureStore.h"
#import "DBCompanyInfo.h"
#import "DBCompaniesManager.h"

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
        
        self.companyHeaderEnabled = YES;
        self.clientHeaderEnabled = YES;
        
        // API version
        [self setValue:[DBAPIClient restAPIVersion] forHeader:@"Version"];
        
        // Locale/Language
        [self setValue:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0] forHeader:@"Language"];
    }
    return self;
}

+ (NSString *)baseUrl {
    return [[DBCompanyInfo db_companyBaseUrl] stringByAppendingString:@"api/"];
}

+ (NSString *)restAPIVersion {
    // 0 - initial API version
    
    return @"0";
}

- (void)disableHeader:(nonnull NSString *)header {
    if (self.reqSerializer) {
        [self.reqSerializer setValue:nil forHTTPHeaderField:header];
    }
}

- (void)setValue:(nonnull NSString *)value forHeader:(nonnull NSString *)header {
    if (self.reqSerializer) {
        [self.reqSerializer setValue:value forHTTPHeaderField:header];
    }
}

- (void)setCompanyHeaderEnabled:(BOOL)companyHeaderEnabled {
    _companyHeaderEnabled = companyHeaderEnabled;
    
    if (companyHeaderEnabled && [DBCompaniesManager selectedCompanyName]) {
        [self setValue:[DBCompaniesManager selectedCompanyName] forHeader:@"namespace"];
    } else {
        [self disableHeader:@"namespace"];
    }
}

- (void)setClientHeaderEnabled:(BOOL)clientHeaderEnabled {
    _clientHeaderEnabled = clientHeaderEnabled;
    
    if(_clientHeaderEnabled && [IHSecureStore sharedInstance].clientId){
        [self setValue:[IHSecureStore sharedInstance].clientId forHeader:@"Client-Id"];
    } else {
        [self disableHeader:@"Client-Id"];
    }
}

@end