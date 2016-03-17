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
#import "DBCustomViewManager.h"
#import "DBShareHelper.h"


NSString *kDBModulesManagerModulesLoaded = @"kDBModulesManagerModulesLoaded";

@interface DBModulesManager ()
@property (strong, nonatomic) NSMutableArray *availableModules;
@end

@implementation DBModulesManager

- (instancetype)init {
    self = [super init];
    
    NSData *companiesData = [DBModulesManager valueForKey:@"availableModules"];
    if (![companiesData isKindOfClass:[NSData class]])
        companiesData = nil;
    
    self.availableModules = [NSKeyedUnarchiver unarchiveObjectWithData:companiesData] ?: [NSMutableArray new];
    
    return self;
}

- (void)fetchModules:(void(^)(BOOL success))callback {
    [[DBAPIClient sharedClient] GET:@"company/modules"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
                                [self processResponse:response];
                                
                                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBModulesManagerModulesLoaded object:nil]];
                                
                                if (callback) callback(YES);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if (callback) callback(NO);
                            }];
}

- (void)processResponse:(NSDictionary *)response {
    NSArray *modules = response[@"modules"];
    
    self.availableModules = [NSMutableArray new];
    for (NSDictionary *moduleDict in modules) {
        [self.availableModules addObject:[[DBModule alloc] init:moduleDict]];
    }
    NSData *modulesData = [NSKeyedArchiver archivedDataWithRootObject:self.availableModules];
    [DBModulesManager setValue:modulesData forKey:@"availableModules"];
}

- (BOOL)moduleEnabled:(DBModuleType)type {
    return [self module:type] != nil;
}

- (DBModule *)module:(DBModuleType)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", @(type)];
    return [[_availableModules filteredArrayUsingPredicate:predicate] firstObject];
}

+ (NSString *)db_managerStorageKey {
    return @"kDBModulesManagerDefaultsInfo";
}

@end

@implementation DBModule

- (instancetype)init:(NSDictionary *)dict {
    self = [super init];
    
    self.type = [[dict getValueForKey:@"type"] integerValue];
    
    if (_type == DBModuleTypeProfileScreenUniversal || _type == DBModuleTypeOrderScreenUniversal) {
        self.info = dict;
    } else {
        self.info = [dict getValueForKey:@"info"] ?: @{};
    }
    
    return self;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBModule alloc] init];
    if(self != nil){
        _type = [[aDecoder decodeObjectForKey:@"_type"] integerValue];
       _info = [aDecoder decodeObjectForKey:@"_info"] ?: @{};
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(_type) forKey:@"_type"];
    [aCoder encodeObject:_info forKey:@"_info"];
}

@end
