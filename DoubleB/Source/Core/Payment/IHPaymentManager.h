//
//  IHPaymentManager.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 03.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDBPaymentErrorDefault;
extern NSString *const kDBPaymentErrorCardNotUnique;
extern NSString *const kDBPaymentErrorWrongCardData;
extern NSString *const kDBPaymentErrorCardLimitExceeded;
extern NSString *const kDBPaymentErrorNoInternetConnection;

typedef NS_ENUM(int16_t, PaymentType) {
    PaymentTypeNotSet = -1,
    PaymentTypeCash = 0,
    PaymentTypeCard = 1,
    PaymentTypeExtraType = 2,
    PaymentTypePayPal = 4,
    PaymentTypeCourierCard = 5
};

@interface IHPaymentManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)paymentTypeAvailable:(PaymentType)type;

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

