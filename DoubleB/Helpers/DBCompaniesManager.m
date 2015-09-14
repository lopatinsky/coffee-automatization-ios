//
//  DBCompaniesManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 24.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompaniesManager.h"
#import "DBServerAPI.h"
#import "DBCompanyInfo.h"
#import "DBAPIClient.h"

#import "NetworkManager.h"

@implementation DBCompaniesManager

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
        if (companies.count <= 1) {
            if (companies.count == 1) {
                [DBCompaniesManager selectCompanyName:companies[0]];
                [[DBCompanyInfo sharedInstance] flushCache];
                [[DBCompanyInfo sharedInstance] flushStoredCache];
            }
            
            [[NetworkManager sharedManager] addPendingUniqueOperation:NetworkOperationFetchCompanyInfo];
        }
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

- (BOOL)companyIsChosen {
    return [DBCompaniesManager valueForKey:@"selectedCompanyNamespace"] != nil;
}

- (NSArray *)companies {
    return [DBCompaniesManager valueForKey:@"companies"];
}

+ (NSString *)selectedCompanyName{
    return [DBCompaniesManager valueForKey:@"selectedCompanyNamespace"];
}

+ (void)selectCompanyName:(NSDictionary *)company {
    [DBCompaniesManager setValue:[company objectForKey:@"namespace"] forKey:@"selectedCompanyNamespace"];
    
    if ([company objectForKey:@"namespace"]) {
        [DBAPIClient sharedClient].companyHeaderEnabled = YES;
    } else {
        [DBAPIClient sharedClient].companyHeaderEnabled = NO;
    }
}

#pragma mark - DBDataManager

+ (NSString *)db_managerStorageKey{
    return @"kDBCompaniesManagerDefaultsInfo";
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
