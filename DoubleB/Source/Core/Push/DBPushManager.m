//
//  DBPushManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBPushManager.h"
#import <Parse/Parse.h>

@interface DBPushManager ()
@end

@implementation DBPushManager

- (instancetype)init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initSdk) name:kDBApplicationConfigDidLoadNotification object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)subscribedChannels {
    return [DBPushManager valueForKey:@"_subscribedChannels"] ?: [NSArray new];
}

- (void)addSubscribedCnahhel:(NSString *)channel {
    NSMutableArray *channels = [[NSMutableArray alloc] initWithArray:[self subscribedChannels]];
    if (![channels containsObject:channel]) {
        [channels addObject:channel];
        
        [DBPushManager setValue:channels forKey:@"_subscribedChannels"];
    }
}

- (NSArray *)pendingChannels {
    return [DBPushManager valueForKey:@"_pendingChannels"] ?: [NSArray new];
}

- (void)addPendingChannel:(NSString *)channel {
    NSMutableArray *channels = [[NSMutableArray alloc] initWithArray:[self pendingChannels]];
    if (![channels containsObject:channel]) {
        [channels addObject:channel];
        
        [DBPushManager setValue:channels forKey:@"_pendingChannels"];
    }
}

- (void)removePendingChannel:(NSString *)channel {
    NSMutableArray *channels = [[NSMutableArray alloc] initWithArray:[self pendingChannels]];
    if ([channels containsObject:channel]) {
        [channels removeObject:channel];
        
        [DBPushManager setValue:channels forKey:@"_pendingChannels"];
    }
}

- (void)initSdk {
    if ([ApplicationConfig sharedInstance].parseAppKey && [ApplicationConfig sharedInstance].parseClientKey) {
        [Parse setApplicationId:[ApplicationConfig sharedInstance].parseAppKey
                      clientKey:[ApplicationConfig sharedInstance].parseClientKey];
    }
}

- (BOOL)sdkInitialized {
    return [ApplicationConfig sharedInstance].parseAppKey.length > 0 && [ApplicationConfig sharedInstance].parseClientKey.length > 0;
}

- (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initSdk];

    [self subscribePending];
}

- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    [self subscribePending];
}

- (void)registerForNotifications {
    [Compatibility registerForNotifications];
}

- (void)subscribeToChannel:(NSString *)channel {
    [Compatibility registerForNotifications];
    
    if ([self sdkInitialized] && [Compatibility isRegisteredForRemoteNotification]) {
        [PFPush subscribeToChannelInBackground:channel block:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self addSubscribedCnahhel:channel];
                [self removePendingChannel:channel];
                
                // Subscribe all pending channels if Parse works correctly
                [self subscribePending];
            } else {
                [self addPendingChannel:channel];
            }
        }];
    } else {
        [self addPendingChannel:channel];
    }
}

- (void)subscribePending {
    if ([self pendingChannels].count > 0) {
        [Compatibility registerForNotifications];
        
        if ([self sdkInitialized] && [Compatibility isRegisteredForRemoteNotification]) {
            NSArray *pendingChannels = [self pendingChannels];
            for (NSString *channel in pendingChannels) {
                [PFPush subscribeToChannelInBackground:channel block:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        [self addSubscribedCnahhel:channel];
                        [self removePendingChannel:channel];
                    }
                }];
            }
        }
    }
}

+ (NSString *)db_managerStorageKey {
    return @"kDBPushManagerDefaults";
}

@end
