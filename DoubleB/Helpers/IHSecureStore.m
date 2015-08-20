//
//  IHSecureStore.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 12.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "IHSecureStore.h"
#import "UICKeyChainStore.h"
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
    
    return self;
}

- (void)setClientId:(NSString *)clientId{
    if(clientId && ![clientId isEqualToString:@"0"] && ![clientId isEqualToString:@""]){
        // Track clientId with crashes
        [[Crashlytics sharedInstance] setUserIdentifier:clientId];
        
        [self.secureStore setString:clientId forKey:@"clientId"];
        [self.secureStore synchronize];
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

@end
