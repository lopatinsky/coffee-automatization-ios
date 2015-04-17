//
//  DBServerAPI.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBServerAPI : NSObject

+ (void)registerUser:(void(^)(BOOL success))callback;

+ (void)registerUserWithBranchParams:(NSDictionary *)branchParams callback:(void(^)(BOOL success))callback;

+ (void)checkNewOrder:(void(^)(NSDictionary *response))success
              failure:(void(^)(NSError *error))failure;

+ (void)createNewOrder:(void(^)(Order *order))success
               failure:(void(^)(NSString *errorTitle, NSString *errorMessage))failure;

+ (void)getWalletInfo:(void(^)(BOOL success, NSDictionary *response))callback;
@end
