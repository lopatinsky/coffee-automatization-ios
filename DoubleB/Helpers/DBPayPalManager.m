//
//  DBPayPalManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 04.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPayPalManager.h"
#import "IHSecureStore.h"
#import "DBAPIClient.h"

#import "PayPalMobile.h"

NSString *const kDBDefaultsLoggedInPayPal = @"kDBDefaultsLoggedInPayPal";

@interface DBPayPalManager ()<PayPalFuturePaymentDelegate>
@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;

@property (copy, nonatomic) void(^successBlock)(BOOL, NSString*);
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
    
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
    
    return self;
}

- (BOOL)loggedIn{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsLoggedInPayPal] boolValue];
}

- (void)setLoggedIn:(BOOL)loggedIn{
    [[NSUserDefaults standardUserDefaults] setObject:@(loggedIn) forKey:kDBDefaultsLoggedInPayPal];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)paymentMetadata{
    return [PayPalMobile clientMetadataID];
}

- (void)bindPayPal:(void(^)(BOOL success, NSString *message))callback{
    self.successBlock = callback;
    [self obtainConsent];
}

- (void)unbindPayPal:(void(^)())callback{
    NSMutableDictionary *params = [NSMutableDictionary new];
    if([IHSecureStore sharedInstance].clientId){
        params[@"client_id"] = [IHSecureStore sharedInstance].clientId;
    }
    
    [[DBAPIClient sharedClient] POST:@"payment/paypal/unbind"
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 self.loggedIn = NO;
                                 
                                 if(callback)
                                     callback();
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 self.loggedIn = NO;
                                 
                                 if(callback)
                                     callback();
                             }];
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
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if([IHSecureStore sharedInstance].clientId){
        params[@"client_id"] = [IHSecureStore sharedInstance].clientId;
    }
    
    NSString *auth_code = authorization[@"response"][@"code"];
    if(auth_code){
        params[@"auth_code"] = auth_code;
    }
    
    [[DBAPIClient sharedClient] POST:@"payment/paypal/bind"
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 self.loggedIn = YES;
                                 
                                 if(_successBlock)
                                     _successBlock(YES, nil);
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 NSString *message;
                                 
                                 if (operation.response.statusCode == 400) {
                                     message = operation.responseObject[@"description"];
                                 }
                                 
                                 if(_successBlock)
                                     _successBlock(NO, message);
                             }];
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
