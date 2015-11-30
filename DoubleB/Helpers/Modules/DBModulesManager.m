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


@interface DBModulesManager ()
@property (strong, nonatomic) NSMutableArray *availableModules;
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
    
    // Switch on all necessary modules
    NSArray *modules = response[@"modules"];
    for (NSDictionary *moduleDict in modules) {
        NSInteger type = [moduleDict getValueForKey:@"type"] ? [[moduleDict getValueForKey:@"type"] integerValue] : -1;
        
        self.availableModules = [NSMutableArray new];
        if (type != -1) {
            [self.availableModules addObject:@(type)];
        }
        
        switch (type) {
            case DBModuleTypeFriendGift:
                [[DBFriendGiftHelper sharedInstance] enableModule:YES withDict:[moduleDict getValueForKey:@"info"]];
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
                [[DBFriendGiftHelper sharedInstance] enableModule:NO withDict:nil];
                break;
            case DBModuleTypeProfileScreenUniversal:
                [[DBFriendGiftHelper sharedInstance] enableModule:NO withDict:nil];
                break;
                
            default:
                break;
        }
    }
}

- (BOOL)moduleEnabled:(DBModuleType)type {
    return [self.availableModules containsObject:@(type)];
}

@end
