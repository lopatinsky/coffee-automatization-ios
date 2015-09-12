//
//  DBServerAPI.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface DBServerAPI : NSObject

+ (void)requestCompanies:(void(^)(NSArray *companies))success
                 failure:(void(^)(NSError *error))failure;

+ (void)registerUser:(void(^)(BOOL success))callback;

+ (void)registerUserWithBranchParams:(NSDictionary *)branchParams callback:(void(^)(BOOL success))callback;

+ (void)updateCompanyInfo:(void(^)(BOOL success, NSDictionary *response))callback;

+ (void)updatePromoInfo:(void(^)(NSDictionary *response))success
                failure:(void(^)(NSError *error))failure;

+ (void)checkNewOrder:(void(^)(NSDictionary *response))success
              failure:(void(^)(NSError *error))failure;

+ (void)createNewOrder:(void(^)(Order *order))success
               failure:(void(^)(NSString *errorTitle, NSString *errorMessage))failure;

+ (void)fetchOrdersHistory:(void(^)(BOOL success, NSError *error))callback;

+ (void)getWalletInfo:(void(^)(BOOL success, NSDictionary *response))callback;

+ (void)requestAddressSuggestions:(NSDictionary *)params callback:(void(^)(BOOL success, NSArray *response))callback;

+ (void)fetchCompanyNewsWithCallback:(void(^)(BOOL success, NSDictionary *response))callback;

+ (void)fetchActivatedPromoCodesWithCallback:(void (^)(BOOL, NSDictionary *))callback;
+ (void)activatePromoCode:(NSString *)code withCallback:(void (^)(BOOL, NSDictionary *))callback;

@end
