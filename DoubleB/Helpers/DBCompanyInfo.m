//
//  CompanyInfo.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfo.h"

@implementation DBCompanyInfo

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBCompanyInfo*instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}


- (id)objectFromPropertyListByName:(NSString *)name{
    NSDictionary *companyInfo = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CompanyInfo"];
    return [companyInfo objectForKey:name];
}

- (NSNumber *)db_companyDefaultColor{
    NSNumber *colorHex = [self objectFromPropertyListByName:@"CompanyColor"];
    
    return colorHex;
}

- (NSString *)db_companyGoogleAnalyticsKey{
    NSString *GAKeyString = [self objectFromPropertyListByName:@"CompanyGAKey"];
    
    return GAKeyString ?: @"";
}

- (NSURL *)db_ndaLicenseUrl{
    NSString *ndaLicenseUrl = [self objectFromPropertyListByName:@"NDALicenseUrlString"];
    return [NSURL URLWithString:ndaLicenseUrl];
}

- (NSURL *)db_aboutAppUrl{
    NSString *ndaLicenseUrl = [self objectFromPropertyListByName:@"AboutAppUrlString"];
    return [NSURL URLWithString:ndaLicenseUrl];
}

@end
