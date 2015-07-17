//
//  IHPaymentManager.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 03.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDBDefaultsAvailablePaymentTypes;

extern NSString *const kDBPaymentErrorDefault;
extern NSString *const kDBPaymentErrorCardNotUnique;
extern NSString *const kDBPaymentErrorWrongCardData;
extern NSString *const kDBPaymentErrorCardLimitExceeded;
extern NSString *const kDBPaymentErrorNoInternetConnection;

@interface IHPaymentManager : NSObject

+ (instancetype)sharedInstance;

/**
* Check on server what payment types available -> Cash | Card
*/
- (void)synchronizePaymentTypes;

- (void)bindNewCardForClient:(NSString *)clientId
           completionHandler:(void(^)(BOOL success, NSString *message, NSDictionary *items))completionHandler;

- (void)unbindCard:(NSString *)cardToken;

/**
* Needed to open WebViewController
*/
- (void)setNavigationController:(UINavigationController *)navigationController;

@property(strong, nonatomic) NSString *orderId;
@property(nonatomic) NSInteger orderDate;

@end

