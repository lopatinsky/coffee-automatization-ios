//
//  CompanyInfo.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPrimaryManager.h"
#import "ManagerProtocol.h"
#import "DBDeliveryType.h"


extern NSString * const DBCompanyInfoNotificationInfoUpdated;

typedef NS_ENUM(NSUInteger, DBCompanyPOS) {
    DBCompanyPOSAutomation = 0,
    DBCompanyPOSIIko = 1
};

typedef NS_ENUM(NSUInteger, DBCompanyType) {
    DBCompanyTypeCafe = 0,
    DBCompanyTypeRestaurant = 1,
    DBCompanyTypeOther = 2
};

@interface DBCompanyInfo : DBPrimaryManager<ManagerProtocol>
@property(strong, nonatomic, readonly) NSString *bundleName;

@property(nonatomic, readonly) DBCompanyPOS companyPOS;
@property(nonatomic, readonly) DBCompanyType type;
@property(strong, nonatomic, readonly) NSString *applicationName;
@property(strong, nonatomic, readonly) NSString *companyDescription;
@property(strong, nonatomic, readonly) NSString *webSiteUrl;
@property(strong, nonatomic, readonly) NSString *phoneNumber;
@property(strong, nonatomic, readonly) NSArray *supportEmails;

@property(strong, nonatomic, readonly) NSArray *deliveryTypes;
@property(strong, nonatomic, readonly) NSArray *deliveryTypeIdList;

@property(strong, nonatomic, readonly) NSArray *deliveryCities;

@property(strong, nonatomic, readonly) NSString *companyPushChannel;
@property(strong, nonatomic, readonly) NSString *clientPushChannel;
@property(strong, nonatomic, readonly) NSString *venuePushChannel;
@property(strong, nonatomic, readonly) NSString *orderPushChannel;

@property(strong, nonatomic, readonly) NSNumber *promocodesIsEnabled;
@property(strong, nonatomic, readonly) NSNumber *subscriptionIsEnabled;

@property(nonatomic, readonly) BOOL friendInvitationEnabled;

@property (nonatomic) BOOL infoLoaded;
- (void)updateInfo DEPRECATED_MSG_ATTRIBUTE("updateInfo is under NetworkManager control");
- (void)updateInfo:(void(^)(BOOL success))callback;

+ (id)objectFromPropertyListByName:(NSString *)name;

+ (NSString *)db_companyBaseUrl;
+ (BOOL)db_proxyApp;
+ (NSNumber *)db_companyDefaultColor;
+ (NSString *)db_companyGoogleAnalyticsKey;

+ (NSString *)db_companyParseApplicationKey;
+ (NSString *)db_companyParseClientKey;

+ (NSURL *)db_aboutAppUrl;
+ (NSURL *)db_licenceUrl;
+ (NSURL *)db_paymentRulesUrl;

// Only for paypal
+ (NSURL *)db_payPalPrivacyPolicy;
+ (NSURL *)db_payPalUserAgreement;

- (DBDeliveryType *)deliveryTypeById:(DeliveryTypeId)typeId;
- (BOOL)isDeliveryTypeEnabled:(DeliveryTypeId)typeId;
- (DBDeliveryType *)defaultDeliveryType;

@end

