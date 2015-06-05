//
//  DBPayPalManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 04.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPayPalManager.h"

#import "PayPalMobile.h"

@interface DBPayPalManager ()<PayPalFuturePaymentDelegate>
@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;
@end

@implementation DBPayPalManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBPayPalManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init{
    self = [super init];
    
    _payPalConfiguration = [[PayPalConfiguration alloc] init];
    
    _payPalConfiguration.merchantName = @"Ultramagnetic Omega Supreme";
    _payPalConfiguration.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.omega.supreme.example/privacy"];
    _payPalConfiguration.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.omega.supreme.example/user_agreement"];
    
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
    
    return self;
}

- (void)authorize{
    [self obtainConsent];
}


- (void)obtainConsent {
    PayPalFuturePaymentViewController *fpViewController;
    fpViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:_payPalConfiguration
                                                                               delegate:self];
    
    if([self.delegate respondsToSelector:@selector(payPalManager:shouldPresentViewController:)]){
        [self.delegate payPalManager:self shouldPresentViewController:fpViewController];
    }
}

- (void)sendAuthorizationToServer:(NSDictionary *)authorization {
    NSData *consentJSONData = [NSJSONSerialization dataWithJSONObject:authorization
                                                              options:0
                                                                error:nil];
}

#pragma mark - PayPalFuturePaymentDelegate methods

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
    if([self.delegate respondsToSelector:@selector(payPalManager:shouldDismissViewController:)]){
        [self.delegate payPalManager:self shouldDismissViewController:futurePaymentViewController];
    }
}

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController
                didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
    [self sendAuthorizationToServer:futurePaymentAuthorization];
    
    if([self.delegate respondsToSelector:@selector(payPalManager:shouldDismissViewController:)]){
        [self.delegate payPalManager:self shouldDismissViewController:futurePaymentViewController];
    }
}

@end
