//
//  DBModulesManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModulesManager.h"
#import "DBAPIClient.h"

#import "DBFriendGiftHelper.h"

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
    NSArray *modules = response[@"modules"];
    
    for (NSDictionary *moduleDict in modules) {
        NSInteger type = [moduleDict getValueForKey:@"type"] ? [[moduleDict getValueForKey:@"type"] integerValue] : -1;
        BOOL enabled = [[moduleDict getValueForKey:@"enable"] boolValue];
        NSDictionary *dict = [moduleDict getValueForKey:@"info"];
        
        switch (type) {
            case DBModuleTypeFriendGift:
                [[DBFriendGiftHelper sharedInstance] enableModule:enabled withDict:dict];
                break;
                
            default:
                break;
        }
    }
}

@end
