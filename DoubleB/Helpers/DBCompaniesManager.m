//
//  DBCompaniesManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 24.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompaniesManager.h"
#import "DBServerAPI.h"
#import "DBAPIClient.h"

NSString *const kDBCompaniesManagerDefaultsInfo = @"kDBCompaniesManagerDefaultsInfo";

@implementation DBCompaniesManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBCompaniesManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    return self;
}

- (BOOL)companiesLoaded {
    return [[DBCompaniesManager valueForKey:@"companiesLoaded"] boolValue];
}

- (void)requestCompanies:(void(^)(BOOL success, NSArray *companies))callback {
    [DBServerAPI requestCompanies:^(NSArray *companies) {
        [DBCompaniesManager setValue:@(YES) forKey:@"companiesLoaded"];
        [DBCompaniesManager setValue:companies forKey:@"companies"];
        
        if(callback)
            callback(YES, companies);
    } failure:^(NSError *error) {
        if(callback)
            callback(NO, nil);
    }];
}

- (BOOL)hasCompanies {
    NSArray *companies = [DBCompaniesManager valueForKey:@"companies"];
    
    BOOL result = NO;
    if([companies count] > 1){
        result = YES;
    }
    
    return result;
}

- (NSArray *)companies {
    return [DBCompaniesManager valueForKey:@"companies"];
}

+ (NSString *)selectedCompanyName{
    return [DBCompaniesManager valueForKey:@"selectedCompanyNamespace"];
}

+ (void)selectCompanyName:(NSString *)name{
    [DBCompaniesManager setValue:name forKey:@"selectedCompanyNamespace"];
    
    if(name){
        [DBAPIClient sharedClient].companyHeaderEnabled = YES;
    } else {
        [DBAPIClient sharedClient].companyHeaderEnabled = NO;
    }
}



#pragma mark - Helper methods

+ (id)valueForKey:(NSString *)key{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDBCompaniesManagerDefaultsInfo];
    return info[key];
}

+ (void)setValue:(id)value forKey:(NSString *)key {
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDBCompaniesManagerDefaultsInfo];
    NSMutableDictionary *mutableInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    
    if(value){
        mutableInfo[key] = value;
    } else {
        [mutableInfo removeObjectForKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableInfo forKey:kDBCompaniesManagerDefaultsInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)deliveryImageName {
    NSString *companyName = [DBCompaniesManager selectedCompanyName];
    if (companyName) {
        if ([companyName isEqualToString:@"perchiniribaris"]) {
            return @"krasnoselskaya";
        } else if ([companyName isEqualToString:@"perchiniribarislublino"]) {
            return @"lublino";
        } else {
            return @"";
        }
    } else {
        return @"";
    }
}

@end
