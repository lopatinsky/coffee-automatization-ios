//
//  CompanyInfo.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfo.h"
#import "DBServerAPI.h"

@implementation DBCompanyInfo

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBCompanyInfo*instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)updateInfo{
    [DBServerAPI updateCompanyInfo:^(BOOL success, NSDictionary *response) {
        if(success){
            
        }
    }];
}


- (id)objectFromPropertyListByName:(NSString *)name{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingString:@"CompanyInfo.plist"];
    NSDictionary *companyInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    
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


@implementation DBDeliveryType

- (instancetype)initWithResponseDict:(NSDictionary *)responseDict{
    self = [super init];
    
    _typeId = [responseDict[@"id"] intValue];
    _typeName = responseDict[@"name"];
    
    _minOrderSum = [responseDict[@"min_sum"] doubleValue];
    
    return self;
}

@end
