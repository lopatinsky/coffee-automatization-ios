//
//  CompanyInfo.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfo.h"
#import "DBAPIClient.h"
#import "DBServerAPI.h"
#import "Order.h"

NSString *const kDBCompanyInfoDidUpdateNotification = @"kDBCompanyInfoDidUpdateNotification";
NSString *const kDBCompanyInfoHardResetNotification = @"kDBCompanyInfoHardResetNotification";

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
    [self updateAllImportantInfo];
    
    return self;
}

- (NSString *)bundleName{
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    return bundleName;
}

- (BOOL)hasAllImportantData{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsHasAllImportantData] boolValue];
}

- (void)setHasAllImportantData:(BOOL)hasAllImportantData{
    [[NSUserDefaults standardUserDefaults] setObject:@(hasAllImportantData) forKey:kDBDefaultsHasAllImportantData];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateAllImportantInfo{
    [self updateAllImportantInfo:nil];
}

- (void)updateAllImportantInfo:(void(^)(BOOL success))callback{
    __block NSInteger numberOfUpdates = 0;
    __block BOOL successUpdates = YES;
    
    void (^block)(BOOL) = ^void(BOOL success){
        successUpdates = successUpdates && success;
        numberOfUpdates++;
        
        if(numberOfUpdates == 2){
            self.hasAllImportantData = successUpdates;
            
            [self notify:successUpdates];
            if(callback)
                callback(successUpdates);
        }
    };
    
    [self updateInfo:block];
    [self synchronizePaymentTypes:block];
}

- (void)notify:(BOOL)success{
    if(success){
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBFirstLaunchNecessaryInfoLoadSuccessNotification object:nil]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBFirstLaunchNecessaryInfoLoadFailureNotification object:nil]];
    }
}

- (void)updateInfo:(void(^)(BOOL success))callback{
    [DBServerAPI updateCompanyInfo:^(BOOL success, NSDictionary *response) {
        if(success){
            _type = [[response getValueForKey:@"companyType"] intValue];
            _applicationName = response[@"appName"];
            
            NSMutableArray *deliveryTypes = [NSMutableArray new];
            for(NSDictionary *typeDict in response[@"deliveryTypes"]){
                [deliveryTypes addObject:[[DBDeliveryType alloc] initWithResponseDict:typeDict]];
            }
            _deliveryTypes = deliveryTypes;
            _deliveryCities = response[@"cities"] ?: @[];
            
            
            _companyPushChannel = [response[@"pushChannels"] getValueForKey:@"company"] ?: @"";
            
            NSString *clientPushChannel = [response[@"pushChannels"] getValueForKey:@"client"] ?: @"";
            _clientPushChannel = [clientPushChannel stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            
            NSString *venuePushChannel = [response[@"pushChannels"] getValueForKey:@"venue"]  ?: @"";
            _venuePushChannel = [venuePushChannel stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            
            NSString *orderPushChannel = [response[@"pushChannels"] getValueForKey:@"order"]  ?: @"";
            _orderPushChannel = [orderPushChannel stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            
            if (![response[@"color"] isEqualToNumber:[DBCompanyInfo objectFromPropertyListByName:@"CompanyColor"]]) {
                [DBCompanyInfo saveObjectToPropteryList:response[@"color"] byKey:@"CompanyColor"];
                [self resetColor];
            }
            
            [self synchronize];
        }
        
        if(callback)
            callback(success);
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBCompanyInfoDidUpdateNotification object:nil]];
    }];
}

- (void)resetColor {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBCompanyInfoHardResetNotification object:nil]];
}

- (void)synchronizePaymentTypes:(void(^)(BOOL success))callback {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *paymentTypes = [defaults objectForKey:kDBDefaultsAvailablePaymentTypes];
    if (!paymentTypes) {
        paymentTypes = @[@(PaymentTypeCash) ];
        [defaults setObject:paymentTypes forKey:kDBDefaultsAvailablePaymentTypes];
        [defaults synchronize];
    }
    
    [[DBAPIClient sharedClient] GET:@"payment/payment_types"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                //NSLog(@"%@", responseObject);
                                NSMutableArray *array = [NSMutableArray array];
                                for (NSDictionary *paymentType in responseObject[@"payment_types"]) {
                                    [array addObject:@([paymentType[@"id"] intValue])];
                                }
                                [defaults setObject:array forKey:kDBDefaultsAvailablePaymentTypes];
                                [defaults synchronize];
                                
                                if(callback)
                                    callback(YES);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(callback)
                                    callback(NO);
                            }];
}

+ (void)saveObjectToPropteryList:(NSObject *)object byKey:(NSString *)key {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSMutableDictionary *companyInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    companyInfo[key] = object;
    [companyInfo writeToFile:path atomically:YES];
}

+ (id)objectFromPropertyListByName:(NSString *)name{
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

+ (BOOL)db_companyChoiceEnabled {
    return [[self objectFromPropertyListByName:@"CompanyChoiceEnabled"] boolValue];
}


+ (NSString *)db_companyParseApplicationKey{
    NSDictionary *parseInfo = [self objectFromPropertyListByName:@"Parse"];
    
    NSString *appId = [parseInfo getValueForKey:@"applicationId"] ?: @"";
    return appId;
}

+ (NSString *)db_companyParseClientKey{
    NSDictionary *parseInfo = [self objectFromPropertyListByName:@"Parse"];
    
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

- (void)loadFromMemory{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsCompanyInfo];
    
    _type = [info getValueForKey:@"type"] ? [[info getValueForKey:@"type"] intValue] : DBCompanyTypeOther;
    _applicationName = [info getValueForKey:@"applicationName"] ?: @"";
    
    NSString *topScreen = [DBCompanyInfo objectFromPropertyListByName:@"TopViewController"];
    if ([topScreen isEqualToString:@"Menu"]) {
        _topScreenType = TVCMenu;
    } else if ([topScreen isEqualToString:@"Order"]) {
        _topScreenType = TVCOrder;
    }
    
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
    
    _currentCompanyName = info[@"_currentCompanyName"] ?: @"";
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
                           @"_currentCompanyName": _currentCompanyName ?: @""};
    
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:kDBDefaultsCompanyInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
