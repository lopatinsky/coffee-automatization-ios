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

- (instancetype)init{
    self = [super init];
    
    [self loadFromMemory];
    [self updateInfo];
    
    return self;
}

- (void)updateInfo{
    [DBServerAPI updateCompanyInfo:^(BOOL success, NSDictionary *response) {
        if(success){
            NSMutableArray *deliveryTypes = [NSMutableArray new];
            for(NSDictionary *typeDict in response[@"deliveryTypes"]){
                [deliveryTypes addObject:[[DBDeliveryType alloc] initWithResponseDict:typeDict]];
            }
            _deliveryTypes = deliveryTypes;
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBFirstLaunchNecessaryInfoLoadedNotification object:nil]];
            
            [self synchronize];
        }
    }];
}


+ (id)objectFromPropertyListByName:(NSString *)name{
//    NSDictionary *companyInfo = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CompanyInfo"];

    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSDictionary *companyInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return [companyInfo objectForKey:name];
}

+ (NSString *)db_companyBaseUrl{
    NSString *baseUrl = [self objectFromPropertyListByName:@"BaseUrl"];
    
    return baseUrl;
}

+ (NSNumber *)db_companyDefaultColor{
    NSNumber *colorHex = [self objectFromPropertyListByName:@"CompanyColor"];
    
    return colorHex;
}

+ (NSString *)db_companyGoogleAnalyticsKey{
    NSString *GAKeyString = [self objectFromPropertyListByName:@"CompanyGAKey"];
    
    return GAKeyString ?: @"";
}

+ (NSURL *)db_ndaLicenseUrl{
    NSString *ndaLicenseUrl = [self objectFromPropertyListByName:@"NDALicenseUrlString"];
    return [NSURL URLWithString:ndaLicenseUrl];
}

+ (NSURL *)db_aboutAppUrl{
    NSString *ndaLicenseUrl = [self objectFromPropertyListByName:@"AboutAppUrlString"];
    return [NSURL URLWithString:ndaLicenseUrl];
}

#pragma mark - Delivery

- (DBDeliveryType *)deliveryTypeById:(DeliveryTypeId)typeId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"typeId == %d", typeId];
    
    DBDeliveryType *type = [[_deliveryTypes filteredArrayUsingPredicate:predicate] firstObject];
    return type;
}

- (NSArray *)deliveryTypeIdList{
    NSMutableArray *typesId = [NSMutableArray new];
    
    for(DBDeliveryType *type in _deliveryTypes){
        [typesId addObject:@(type.typeId)];
    }
    
    return typesId;
}

- (BOOL)idDeliveryTypeEnabled:(DeliveryTypeId)typeId{
    return [self deliveryTypeById:typeId] != nil;
}


#pragma mark - Helper methods

- (void)loadFromMemory{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsCompanyInfo];
    
    NSData *deliveryTypesData = info[@"deliveryTypes"];
    if(deliveryTypesData){
        _deliveryTypes = [NSKeyedUnarchiver unarchiveObjectWithData:deliveryTypesData] ?: @[];
    }
}

- (void)synchronize{
    NSData *deliveryTypesData = [NSKeyedArchiver archivedDataWithRootObject:_deliveryTypes];
    NSDictionary *info = @{@"deliveryTypes": deliveryTypesData};
    
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:kDBDefaultsCompanyInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
