//
//  CompanyInfo.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DeliveryTypeId) {
    DeliveryTypeIdShipping = 2,
    DeliveryTypeIdInRestaurant = 1,
    DeliveryTypeIdTakeaway = 0
};

@interface DBCompanyInfo : NSObject
+ (instancetype)sharedInstance;

@property(strong, nonatomic, readonly) NSString *applicationName;
@property(strong, nonatomic, readonly) NSString *companyDescription;
@property(strong, nonatomic, readonly) NSString *webSiteUrl;
@property(strong, nonatomic, readonly) NSString *phoneNumber;
@property(strong, nonatomic, readonly) NSArray *supportEmails;



@property(strong, nonatomic, readonly) NSArray *deliveryCities;

- (NSNumber *)db_companyDefaultColor;
- (NSString *)db_companyGoogleAnalyticsKey;
- (NSURL *)db_ndaLicenseUrl;
- (NSURL *)db_aboutAppUrl;
@end


@interface DBDeliveryType : NSObject
@property (nonatomic, readonly) DeliveryTypeId typeId;
@property (strong, nonatomic, readonly) NSString *typeName;

@property (nonatomic, readonly) double minOrderSum;

@property (nonatomic, readonly) BOOL useTimeSelection;
@property (nonatomic, readonly) int minTimeInterval;
@property (nonatomic, readonly) int maxTimeInterva;

@property (strong, nonatomic, readonly) NSArray *timeSlots;
@end

@interface DBTimeSlot : NSObject
@property (strong, nonatomic, readonly) NSString *slotId;
@property (strong, nonatomic, readonly) NSString *slotTitle;
@property (strong, nonatomic, readonly) NSDictionary *slotDict;
@end
