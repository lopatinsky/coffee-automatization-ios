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
#import "DBCompaniesViewController.h"

#import "NetworkManager.h"

@implementation DBCompany

- (instancetype)initWithResponseDict:(NSDictionary *)dict {
    self = [super init];
    
    self.companyNamespace = [dict getValueForKey:@"namespace"] ?: @"";
    self.companyName = [dict getValueForKey:@"name"] ?: @"";
    self.companyDescription = [dict getValueForKey:@"description"] ?: @"";
    self.companyImageUrl = [dict getValueForKey:@"image"] ?: @"";
    
    return self;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBCompany alloc] init];
    if(self != nil){
        _companyNamespace = [aDecoder decodeObjectForKey:@"_companyNamespace"];
        _companyName = [aDecoder decodeObjectForKey:@"_companyName"];
        _companyDescription = [aDecoder decodeObjectForKey:@"_companyDescription"];
        _companyImageUrl = [aDecoder decodeObjectForKey:@"_companyImageUrl"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_companyNamespace forKey:@"_companyNamespace"];
    [aCoder encodeObject:_companyName forKey:@"_companyName"];
    [aCoder encodeObject:_companyDescription forKey:@"_companyDescription"];
    [aCoder encodeObject:_companyImageUrl forKey:@"_companyImageUrl"];
}

@end

@implementation DBCompaniesManager

- (BOOL)companiesLoaded {
    return [[DBCompaniesManager valueForKey:@"companiesLoaded"] boolValue];
}

- (void)requestCompanies:(void(^)(BOOL success, NSArray *companies))callback {
    [DBServerAPI requestCompanies:^(NSArray *companies) {
        // Assemble companies
        NSMutableArray *array = [NSMutableArray new];
        for (NSDictionary *companyDict in companies) {
            [array addObject:[[DBCompany alloc] initWithResponseDict:companyDict]];
        }
        [DBCompaniesManager overrideCompanies:array];
        
        if (!self.companiesLoaded){
            if (companies.count == 1) {
                [DBCompaniesManager selectCompany:[array firstObject]];
                
                [[DBCompanyInfo sharedInstance] flushStoredCache];
            }
        }
        
        [DBCompaniesManager setValue:@(YES) forKey:@"companiesLoaded"];
        
        if(callback)
            callback(YES, companies);
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        
        if(callback)
            callback(NO, nil);
    }];
}

+ (void)overrideCompanies:(NSArray *)companies {
    NSData *companiesData = [NSKeyedArchiver archivedDataWithRootObject:companies];
    [DBCompaniesManager setValue:companiesData forKey:@"companies"];
}

- (BOOL)hasCompanies {
    return [self companies].count > 1;
}

- (BOOL)companyIsChosen {
    return [DBCompaniesManager valueForKey:@"selectedCompanyNamespace"] != nil;
}

- (NSArray *)companies {
    NSData *companiesData = [DBCompaniesManager valueForKey:@"companies"];
    if (![companiesData isKindOfClass:[NSData class]])
        companiesData = nil;
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:companiesData];
}

+ (DBCompany *)selectedCompany {
    NSArray *companies = [DBCompaniesManager sharedInstance].companies;
    NSString *selectedCompNamespace = [self selectedCompanyNamespace];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyNamespace == %@", selectedCompNamespace];
    
    return [[companies filteredArrayUsingPredicate:predicate] firstObject];
}

+ (NSString *)selectedCompanyNamespace{
    return [DBCompaniesManager valueForKey:@"selectedCompanyNamespace"];
}

+ (void)selectCompany:(DBCompany *)company {
    [DBCompaniesManager setValue:company.companyNamespace forKey:@"selectedCompanyNamespace"];
    
    if (company.companyNamespace) {
        [DBAPIClient sharedClient].companyHeaderEnabled = YES;
    } else {
        [DBAPIClient sharedClient].companyHeaderEnabled = NO;
    }
}

#pragma mark - DBManagerProtocol
- (void)flushCache {
    [DBAPIClient sharedClient].companyHeaderEnabled = NO;
    [DBCompaniesManager removeAllValues];
}

- (void)flushStoredCache {
    [DBAPIClient sharedClient].companyHeaderEnabled = NO;
    [DBCompaniesManager removeAllValues];
}

#pragma mark - DBDataManager

+ (NSString *)db_managerStorageKey{
    return @"kDBCompaniesManagerDefaultsInfo";
}

@end
