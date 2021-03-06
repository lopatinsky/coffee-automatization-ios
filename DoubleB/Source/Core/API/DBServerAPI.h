//
//  DBServerAPI.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

#import <CoreLocation/CoreLocation.h>

@class DBCity;

@interface DBServerAPI : NSObject

+ (void)fetchAppConfiguration:(void (^)(BOOL, NSDictionary* response))callback;

+ (void)requestCompanies:(void(^)(NSArray *companies))success
                 failure:(void(^)(NSError *error))failure;

+ (void)registerUser:(void(^)(BOOL success))callback;

+ (void)registerUser:(CLLocation *)location callback:(void (^)(BOOL, DBCity *))callback;

+ (void)registerUserWithBranchParams:(NSDictionary *)branchParams callback:(void(^)(BOOL success))callback;

+ (void)recoverClientId:(NSString *)clientId fromId:(NSString *)oldClientId callback:(void(^)(BOOL success))callback;

+ (void)sendUserInfo:(void(^)(BOOL success))callback;

+ (void)updateCompanyInfo:(void(^)(BOOL success, NSDictionary *response))callback;

+ (void)updatePromoInfo:(void(^)(NSDictionary *response))success
                failure:(void(^)(NSError *error))failure;

+ (void)checkNewOrder:(void(^)(NSDictionary *response))success
              failure:(void(^)(NSError *error))failure;

+ (void)createNewOrder:(void(^)(Order *order, NSDictionary *responce))success
               failure:(void(^)(NSString *errorTitle, NSString *errorMessage))failure;

+ (void)fetchOrdersHistory:(void(^)(BOOL success, NSError *error))callback;

+ (void)getWalletInfo:(void(^)(BOOL success, NSDictionary *response))callback;

+ (void)requestAddressSuggestions:(NSDictionary *)params callback:(void(^)(BOOL success, NSArray *response))callback;

+ (void)fetchCompanyNewsWithCallback:(void(^)(BOOL success, NSDictionary *response))callback;

+ (void)fetchActivatedPromoCodesWithCallback:(void (^)(BOOL, NSDictionary *))callback;
+ (void)activatePromoCode:(NSString *)code withCallback:(void (^)(BOOL, NSDictionary *))callback;

+ (NSDictionary *)assembleClientInfo;
+ (NSDictionary *)assemblyPaymentInfo;
+ (void)assembleTimeIntoParams:(NSMutableDictionary *)params;
+ (void)assembleDeliveryInfoIntoParams:(NSMutableDictionary *)params encode:(BOOL)encode;

@end
