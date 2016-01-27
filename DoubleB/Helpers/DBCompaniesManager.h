//
//  DBCompaniesManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 24.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPrimaryManager.h"

@interface DBCompany : NSObject<NSCoding>

@property (strong, nonatomic) NSString *companyNamespace;

@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *companyDescription;
@property (strong, nonatomic) NSString *companyImageUrl;

- (instancetype)initWithResponseDict:(NSDictionary *)dict;

@end

@interface DBCompaniesManager : DBPrimaryManager

@property (nonatomic, readonly) BOOL companiesLoaded;

@property (nonatomic, readonly) BOOL hasCompanies;
@property (strong, nonatomic) NSArray *companies;

// Selected company (Using for apps, that aggregate more than 1 company)
+ (DBCompany *)selectedCompany;
+ (NSString *)selectedCompanyNamespace;
+ (void)selectCompany:(DBCompany *)company;

- (BOOL)companyIsChosen;
- (void)requestCompanies:(void(^)(BOOL success, NSArray *companies))callback;
                         
@end
