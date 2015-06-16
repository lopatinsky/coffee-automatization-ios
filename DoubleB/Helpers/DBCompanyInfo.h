//
//  CompanyInfo.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBDeliveryType.h"

@interface DBCompanyInfo : NSObject
+ (instancetype)sharedInstance;

@property(strong, nonatomic, readonly) NSString *applicationName;
@property(strong, nonatomic, readonly) NSString *companyDescription;
@property(strong, nonatomic, readonly) NSString *webSiteUrl;
@property(strong, nonatomic, readonly) NSString *phoneNumber;
@property(strong, nonatomic, readonly) NSArray *supportEmails;

@property(strong, nonatomic, readonly) NSArray *deliveryTypes;
@property(strong, nonatomic, readonly) NSArray *deliveryTypeIdList;

@property(strong, nonatomic, readonly) NSArray *deliveryCities;

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

- (DBDeliveryType *)deliveryTypeById:(DeliveryTypeId)typeId;
- (BOOL)isDeliveryTypeEnabled:(DeliveryTypeId)typeId;

@end

