//
//  CompanyInfo.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfo.h"
#import "DBServerAPI.h"
#import "IHSecureStore.h"

#import <Parse/PFPush.h>

NSString * const DBCompanyInfoNotificationInfoUpdated = @"DBCompanyInfoNotificationInfoUpdated";

@implementation DBCompanyInfo

- (instancetype)init{
    self = [super init];
    
    [self loadFromMemory];
    
    return self;
}

- (NSString *)bundleName{
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    return bundleName;
}

- (BOOL)infoLoaded {
    return [[DBCompanyInfo valueForKey:@"infoLoaded"] boolValue];
}

- (NSString *)companyDescription {
    return [DBCompanyInfo valueForKey:@"companyDescription"] ?: @"";
}

- (NSString *)webSiteUrl {
    return [DBCompanyInfo valueForKey:@"webSiteUrl"] ?: @"";
}

- (NSString *)phoneNumber {
    return [DBCompanyInfo valueForKey:@"phoneNumber"] ?: @"";
}

- (void)updateInfo {
    [self updateInfo:nil];
}

- (void)updateInfo:(void(^)(BOOL success))callback{
    [DBServerAPI updateCompanyInfo:^(BOOL success, NSDictionary *response) {
        if (success) {
            [DBCompanyInfo setValue:@(YES) forKey:@"infoLoaded"];
            
            _companyPOS = [[response getValueForKey:@"back_end"] intValue];
            _type = [[response getValueForKey:@"screen_logic_type"] intValue];
            _applicationName = [response getValueForKey:@"app_name"] ?: @"";
            
            [DBCompanyInfo setValue:([response getValueForKey:@"site"] ?: @"") forKey:@"webSiteUrl"];
            [DBCompanyInfo setValue:([response getValueForKey:@"phone"] ?: @"") forKey:@"phoneNumber"];
            [DBCompanyInfo setValue:([response getValueForKey:@"description"] ?: @"") forKey:@"companyDescription"];
            
            NSMutableArray *deliveryTypes = [NSMutableArray new];
            for(NSDictionary *typeDict in response[@"delivery_types"]){
                [deliveryTypes addObject:[[DBDeliveryType alloc] initWithResponseDict:typeDict]];
            }
            _deliveryTypes = deliveryTypes;
            _deliveryCities = response[@"cities"] ?: @[];
            
            _supportEmails = response[@"emails"] ?: @[];
            
            
            _companyPushChannel = [response[@"push_channels"] getValueForKey:@"company"] ?: @"";
            [PFPush subscribeToChannelInBackground:_companyPushChannel];
            
            NSString *clientPushChannel = [response[@"push_channels"] getValueForKey:@"client"] ?: @"";
            _clientPushChannel = [clientPushChannel stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            _clientPushChannel = [NSString stringWithFormat:_clientPushChannel, [IHSecureStore sharedInstance].clientId];
            [PFPush subscribeToChannelInBackground:_clientPushChannel];
            
            NSString *venuePushChannel = [response[@"push_channels"] getValueForKey:@"venue"]  ?: @"";
            _venuePushChannel = [venuePushChannel stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            
            NSString *orderPushChannel = [response[@"push_channels"] getValueForKey:@"order"]  ?: @"";
            _orderPushChannel = [orderPushChannel stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            
            _friendInvitationEnabled = [[response[@"share_invitation"] getValueForKey:@"enabled"] boolValue];
            
            _promocodesIsEnabled = response[@"promo_code_active"] ?: @(NO);
            
            [self synchronize];
            
            [self notifyObserverOf:DBCompanyInfoNotificationInfoUpdated];
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

+ (BOOL)db_proxyApp{
    BOOL proxy = [[self objectFromApplicationPreferencesByName:@"Proxy"] boolValue];
    
    return proxy;
}

+ (DBMenuType)db_menuType {
    NSString *menuTypeString = [[self objectFromPropertyListByName:@"AppConfiguration"] objectForKey:@"MenuType"];
    
    return [menuTypeString isEqualToString:@"Skeleton"] ? DBMenuTypeSkeleton : DBMenuTypeSimple;
}

+ (id)db_companyDefaultColor {
    id colorHex = [self objectFromApplicationPreferencesByName:@"CompanyColor"];
    
    return colorHex;
}

+ (NSString *)db_companyGoogleAnalyticsKey {
    NSString *GAKeyString = [self objectFromApplicationPreferencesByName:@"CompanyGAKey"];
    
    return GAKeyString ?: @"";
}

+ (NSString *)db_companyParseApplicationKey {
    NSDictionary *parseInfo = [self objectFromApplicationPreferencesByName:@"Parse"];
    
    NSString *appId = [parseInfo getValueForKey:@"applicationId"] ?: @"_";
    return appId;
}

+ (NSString *)db_companyParseClientKey {
    NSDictionary *parseInfo = [self objectFromApplicationPreferencesByName:@"Parse"];
    
    NSString *clientKey = [parseInfo getValueForKey:@"clientKey"] ?: @"_";
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

- (DBDeliveryType *)defaultDeliveryType {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSDictionary *companyInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *prefs = [companyInfo objectForKey:@"AppConfiguration"];
    
    NSString *deliveryTypeString = [prefs objectForKey:@"DefaultDeliveryType"];
    DeliveryTypeId deliveryTypeId = DeliveryTypeIdTakeaway;
    if ([deliveryTypeString isEqualToString:@"Shipping"]) {
        deliveryTypeId = DeliveryTypeIdShipping;
    }
    
    DBDeliveryType *result = [self deliveryTypeById:deliveryTypeId];
    if (!result)
        result = [_deliveryTypes firstObject];
    
    return result;
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
    _companyPushChannel = [pushChannels getValueForKey:@"_companyPushChannel"] ?: @"";
    _clientPushChannel = [pushChannels getValueForKey:@"_clientPushChannel"] ?: @"";
    _venuePushChannel = [pushChannels getValueForKey:@"_venuePushChannel"] ?: @"";
    _orderPushChannel = [pushChannels getValueForKey:@"_orderPushChannel"] ?: @"";
    
    _supportEmails = info[@"supportEmails"];
    _deliveryCities = info[@"_deliveryCities"];
    _promocodesIsEnabled = info[@"promocodeIsEnabled"] ?: @NO;
    _friendInvitationEnabled = [info[@"_friendInvitationEnabled"] boolValue];
}

- (void)synchronize {
    NSData *deliveryTypesData = [NSKeyedArchiver archivedDataWithRootObject:_deliveryTypes];
    
    NSDictionary *pushChannels = @{@"_companyPushChannel":_companyPushChannel ?: @"",
                                   @"_clientPushChannel":_clientPushChannel ?: @"",
                                   @"_venuePushChannel":_venuePushChannel ?: @"",
                                   @"_orderPushChannel":_orderPushChannel ?: @""};
    
    NSDictionary *info = @{@"type": @(_type),
                           @"applicationName": _applicationName,
                           @"deliveryTypes": deliveryTypesData,
                           @"pushChannels": pushChannels,
                           @"supportEmails": _supportEmails,
                           @"_deliveryCities": _deliveryCities,
                           @"_friendInvitationEnabled": @(_friendInvitationEnabled),
                           @"promocodeIsEnabled": _promocodesIsEnabled};
    
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:kDBDefaultsCompanyInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - DBDataManager

+ (NSString *)db_managerStorageKey {
    return @"DBDefaultsCompanyInfo";
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
    
    [DBCompanyInfo setValue:@(NO) forKey:@"infoLoaded"];
}

@end

