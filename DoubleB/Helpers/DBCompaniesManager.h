//
//  DBCompaniesManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 24.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBCompaniesManager : NSObject
+ (instancetype)sharedInstance;

@property (strong, nonatomic) NSString *deliveryImageName;

// Selected company name/namespace(Using for apps, that aggregate more than 1 company)
+ (NSString *)selectedCompanyName;
+ (void)selectCompanyName:(NSString *)name;

+ (void)requesCompanies:(void(^)(BOOL success, NSArray *companies))callback;
                         
@end
