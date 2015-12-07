//
//  DBModulesManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModulesManager.h"
#import "DBAPIClient.h"

#import "DBSubscriptionManager.h"
#import "DBFriendGiftHelper.h"
#import "DBUniversalModulesManager.h"
#import "DBGeoPushManager.h"

typedef NS_ENUM(NSInteger, DBModuleType) {
    DBModuleTypeSubscription = 0,
    
    DBModuleTypeFriendGift = 1,
    DBModuleTypeFriendGiftMivako = 7,
    
    DBModuleTypeFriendInvitation = 2,
    DBModuleTypeProfileScreenUniversal = 4,
    DBModuleTypeGeoPush = 5,
    
    DBModuleTypeLast // Enum item for iteration, not in use
};

@interface DBModulesManager ()
@end

@implementation DBModulesManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBModulesManager *instance = nil;
    dispatch_once(&once, ^{ instance = [DBModulesManager new]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    return self;
}

- (void)fetchModules:(void(^)(BOOL success))callback {
    [[DBAPIClient sharedClient] GET:@"company/modules"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
                                [self processResponse:response];
                                if (callback) callback(YES);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if (callback) callback(NO);
                            }];
}

- (void)processResponse:(NSDictionary *)response {
    NSMutableArray *appModules = [NSMutableArray new];
    for (int i = 0; i < DBModuleTypeLast; i++){

    }
    
    // Switch on all necessary modules
    NSArray *modules = response[@"modules"];
    for (NSDictionary *moduleDict in modules) {
        NSInteger type = [moduleDict getValueForKey:@"type"] ? [[moduleDict getValueForKey:@"type"] integerValue] : -1;
        
        switch (type) {
            case DBModuleTypeFriendGift:
                [[DBFriendGiftHelper sharedInstance] enableModule:YES withDict:@{@"type": @(DBFriendGiftTypeCommon), @"info":moduleDict}];
                break;
            case DBModuleTypeFriendGiftMivako:
                [[DBFriendGiftHelper sharedInstance] enableModule:YES withDict:@{@"type": @(DBFriendGiftTypeFree), @"info":moduleDict}];
                break;
            case DBModuleTypeProfileScreenUniversal:
                [[DBUniversalModulesManager sharedInstance] enableModule:YES withDict:moduleDict];
                break;
            case DBModuleTypeSubscription:
                [[DBSubscriptionManager sharedInstance] enableModule:YES withDict:moduleDict];
                break;
            case DBModuleTypeGeoPush:
                [[DBGeoPushManager sharedInstance] enableModule:YES withDict:moduleDict];
                break;
        }
        
        [appModules removeObject:@(type)];
    }
    
    // Switch off all modules that not switched on
    for (NSNumber *type in appModules) {
        switch (type.integerValue) {
            case DBModuleTypeFriendGift:
            case DBModuleTypeFriendGiftMivako:
                [[DBFriendGiftHelper sharedInstance] enableModule:NO withDict:nil];
                break;
            case DBModuleTypeProfileScreenUniversal:
                [[DBFriendGiftHelper sharedInstance] enableModule:NO withDict:nil];
                break;
            case DBModuleTypeSubscription:
                [[DBSubscriptionManager sharedInstance] enableModule:NO withDict:nil];
                break;
            case DBModuleTypeGeoPush:
                [[DBGeoPushManager sharedInstance] enableModule:NO withDict:nil];
                break;
                
            default:
                break;
        }
    }
}

@end
