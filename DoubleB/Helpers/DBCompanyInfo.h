//
//  CompanyInfo.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBCompanyInfo : NSObject
+ (instancetype)sharedInstance;

- (NSNumber *)db_companyDefaultColor;
- (NSString *)db_companyGoogleAnalyticsKey;
- (NSURL *)db_ndaLicenseUrl;
- (NSURL *)db_aboutAppUrl;
@end
