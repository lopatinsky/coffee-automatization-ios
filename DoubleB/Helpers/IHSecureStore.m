//
//  IHSecureStore.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 12.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "IHSecureStore.h"
#import "UICKeyChainStore.h"
#import "DBAPIClient.h"
#import <Crashlytics/Crashlytics.h>

@interface IHSecureStore ()
@property(strong, nonatomic) UICKeyChainStore *secureStore;
@end

@implementation IHSecureStore

+ (id)sharedInstance
{
    static IHSecureStore *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [IHSecureStore new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    self.secureStore = [UICKeyChainStore keyChainStore];
//    [self.secureStore removeAllItems];
    
    return self;
}

- (void)setClientId:(NSString *)clientId{
    if(clientId && ![clientId isEqualToString:@"0"] && ![clientId isEqualToString:@""]){
        [self.secureStore setString:clientId forKey:@"clientId"];
        [self.secureStore synchronize];
        
        // Track clientId with crashes
        [[Crashlytics sharedInstance] setUserIdentifier:clientId];
        [DBAPIClient sharedClient].clientHeaderEnabled = YES;
    }
}

- (NSString *)clientId {
    NSString *clientId;

    clientId = self.secureStore[@"clientId"];

    
    if ([clientId isEqualToString:@"0"]) {
        return nil;
    } else {
        return clientId;
    }
}

- (NSData *)dataForKey:(NSString *)key {
    return [self.secureStore dataForKey:key];
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
    [self.secureStore setData:data forKey:key];
    [self.secureStore synchronize];
}

- (void)removeAll {
    [self.secureStore removeAllItems];
    [self.secureStore synchronize];
}

@end
