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

- (NSString *)bundleName{
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    return bundleName;
}

- (void)updateInfo {
    [self updateInfo:nil];
}

- (void)updateInfo:(void(^)(BOOL success))callback{
    [DBServerAPI updateCompanyInfo:^(BOOL success, NSDictionary *response) {
        if(success){
            _type = [[response getValueForKey:@"screen_logic_type"] intValue];
            _applicationName = response[@"app_name"];
            
            NSMutableArray *deliveryTypes = [NSMutableArray new];
            for(NSDictionary *typeDict in response[@"delivery_types"]){
                [deliveryTypes addObject:[[DBDeliveryType alloc] initWithResponseDict:typeDict]];
            }
            _deliveryTypes = deliveryTypes;
            _deliveryCities = response[@"cities"] ?: @[];
            
            _supportEmails = response[@"emails"] ?: @[];
            
            
            _companyPushChannel = [response[@"push_channels"] getValueForKey:@"company"] ?: @"";
            
            NSString *clientPushChannel = [response[@"push_channels"] getValueForKey:@"client"] ?: @"";
            _clientPushChannel = [clientPushChannel stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            
            NSString *venuePushChannel = [response[@"push_channels"] getValueForKey:@"venue"]  ?: @"";
            _venuePushChannel = [venuePushChannel stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            
            NSString *orderPushChannel = [response[@"push_channels"] getValueForKey:@"order"]  ?: @"";
            _orderPushChannel = [orderPushChannel stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            
            _friendInvitationEnabled = [response[@"share_invitation"][@"enabled"] boolValue];
            
            _promocodesIsEnabled = response[@"promo_code_active"] ?: @(NO);
            
            [self synchronize];
        }
        
        if(callback)
            callback(success);
    }];
}

+ (id)objectFromPropertyListByName:(NSString *)name {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSDictionary *companyInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return [companyInfo objectForKey:name];
}

+ (id)objectFromApplicationPreferencesByName:(NSString *)name {
    return [[self objectFromPropertyListByName:@"Preferences"] objectForKey:name];
}

+ (NSString *)db_companyBaseUrl {
    NSString *baseUrl = [self objectFromApplicationPreferencesByName:@"BaseUrl"];
    
    return baseUrl;
}

+ (NSNumber *)db_companyDefaultColor {
    NSNumber *colorHex = [self objectFromApplicationPreferencesByName:@"CompanyColor"];
    
    return colorHex;
}

+ (NSString *)db_companyGoogleAnalyticsKey {
    NSString *GAKeyString = [self objectFromApplicationPreferencesByName:@"CompanyGAKey"];
    
    return GAKeyString ?: @"";
}

+ (NSString *)db_companyParseApplicationKey {
    NSDictionary *parseInfo = [self objectFromApplicationPreferencesByName:@"Parse"];
    
    NSString *appId = [parseInfo getValueForKey:@"applicationId"] ?: @"";
    return appId;
}

+ (NSString *)db_companyParseClientKey {
    NSDictionary *parseInfo = [self objectFromApplicationPreferencesByName:@"Parse"];
    
    NSString *clientKey = [parseInfo getValueForKey:@"clientKey"] ?: @"";
    return clientKey;
}


+ (NSURL *)db_aboutAppUrl{
    NSString *urlString = [[self db_companyBaseUrl] stringByAppendingString:@"/docs/about.html"];
    
    return [NSURL URLWithString:urlString];
}

+ (NSURL *)db_licenceUrl{
    NSString *urlString = [[self db_companyBaseUrl] stringByAppendingString:@"/docs/licence_agreement.html"];
    
    return [NSURL URLWithString:urlString];
}

+ (NSURL *)db_paymentRulesUrl{
    NSString *urlString = [[self db_companyBaseUrl] stringByAppendingString:@"/docs/payment_rules.html"];
    
    return [NSURL URLWithString:urlString];
}

#pragma mark - PayPal

+ (NSURL *)db_payPalPrivacyPolicy{
    NSString *urlString = [[self db_companyBaseUrl] stringByAppendingString:@"docs/paypal_privacy_policy.html"];
    
    return [NSURL URLWithString:urlString];
}

+ (NSURL *)db_payPalUserAgreement{
    NSString *urlString = [[self db_companyBaseUrl] stringByAppendingString:@"docs/paypal_user_agreement.html"];
    
    return [NSURL URLWithString:urlString];
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

- (BOOL)isDeliveryTypeEnabled:(DeliveryTypeId)typeId{
    return [self deliveryTypeById:typeId] != nil;
}


#pragma mark - Helper methods

- (void)loadFromMemory {
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsCompanyInfo];
    
    _type = [info getValueForKey:@"type"] ? [[info getValueForKey:@"type"] intValue] : DBCompanyTypeOther;
    _applicationName = [info getValueForKey:@"applicationName"] ?: @"";
    
    NSData *deliveryTypesData = info[@"deliveryTypes"];
    if(deliveryTypesData){
        _deliveryTypes = [NSKeyedUnarchiver unarchiveObjectWithData:deliveryTypesData] ?: @[];
    }
    
    NSDictionary *pushChannels = info[@"pushChannels"];
    _companyPushChannel = pushChannels[@"_companyPushChannel"];
    _clientPushChannel = pushChannels[@"_clientPushChannel"];
    _venuePushChannel = pushChannels[@"_venuePushChannel"];
    _orderPushChannel = pushChannels[@"_orderPushChannel"];
    
    _deliveryCities = info[@"_deliveryCities"];
    _promocodesIsEnabled = info[@"promocodeIsEnabled"];
    _friendInvitationEnabled = [info[@"_friendInvitationEnabled"] boolValue];
}

- (void)synchronize{
    NSData *deliveryTypesData = [NSKeyedArchiver archivedDataWithRootObject:_deliveryTypes];
    
    NSDictionary *pushChannels = @{@"_companyPushChannel":_companyPushChannel,
                                   @"_clientPushChannel":_clientPushChannel,
                                   @"_venuePushChannel":_venuePushChannel,
                                   @"_orderPushChannel":_orderPushChannel};
    
    NSDictionary *info = @{@"type": @(_type),
                           @"applicationName": _applicationName,
                           @"deliveryTypes": deliveryTypesData,
                           @"pushChannels": pushChannels,
                           @"_deliveryCities": _deliveryCities,
                           @"_friendInvitationEnabled": @(_friendInvitationEnabled),
                           @"promocodeIsEnabled": _promocodesIsEnabled};
    
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:kDBDefaultsCompanyInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - ManagerProtocol

- (void)flushCache {
    _applicationName = @"";
    
    _deliveryTypes = @[];
    _deliveryCities = @[];
    
    _supportEmails = @[];
}

- (void)flushStoredCache {
    [self flushCache];
    [self synchronize];
}

@end

