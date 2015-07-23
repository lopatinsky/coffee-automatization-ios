//
//  CompanyInfo.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBDeliveryType.h"


typedef NS_ENUM(NSUInteger, DBCompanyType) {
    DBCompanyTypeCafe = 0,
    DBCompanyTypeRestaurant = 1,
    DBCompanyTypeOther = 2
};

typedef NS_ENUM(NSUInteger, TopViewControllerType) {
    TVCMenu = 0,
    TVCOrder = 1
};

@interface DBCompanyInfo : NSObject
+ (instancetype)sharedInstance;

@property(strong, nonatomic, readonly) NSString *bundleName;

@property(nonatomic, readonly) DBCompanyType type;
@property(nonatomic, readonly) TopViewControllerType topScreenType;
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

@property (strong, nonatomic) NSString *deliveryImageName;

@property(strong, nonatomic) NSString *currentCompanyName;

- (void)updateInfo;

+ (id)objectFromPropertyListByName:(NSString *)name;
+ (NSString *)db_companyBaseUrl;
+ (NSNumber *)db_companyDefaultColor;
+ (NSString *)db_companyGoogleAnalyticsKey;

+ (NSString *)db_companyParseApplicationKey;
+ (NSString *)db_companyParseClientKey;

+ (NSURL *)db_aboutAppUrl;
+ (NSURL *)db_licenceUrl;
+ (NSURL *)db_paymentRulesUrl;

+ (BOOL)db_companyChoiceEnabled;
// Only for paypal
+ (NSURL *)db_payPalPrivacyPolicy;
+ (NSURL *)db_payPalUserAgreement;

- (DBDeliveryType *)deliveryTypeById:(DeliveryTypeId)typeId;
- (BOOL)isDeliveryTypeEnabled:(DeliveryTypeId)typeId;

@end

