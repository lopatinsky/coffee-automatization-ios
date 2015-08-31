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
#import "DBCompanyInfo.h"

#import "PayPalMobile.h"

NSString *const kDBDefaultsLoggedInPayPal = @"kDBDefaultsLoggedInPayPal";

@interface DBPayPalManager ()<PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate>
@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;

@property (copy, nonatomic) void(^successBlock)(DBPayPalBindingState, NSString*);
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
    
    _payPalConfiguration.merchantName = [DBCompanyInfo sharedInstance].applicationName;
    _payPalConfiguration.merchantPrivacyPolicyURL = [DBCompanyInfo db_payPalPrivacyPolicy];
    _payPalConfiguration.merchantUserAgreementURL = [DBCompanyInfo db_payPalUserAgreement];
    
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
    
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

- (void)bindPayPal:(void(^)(DBPayPalBindingState state, NSString *message))callback{
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
//    PayPalProfileSharingViewController *psViewController;
//    NSSet *scopes = [NSSet setWithArray:@[kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]];
//    
//    psViewController = [[PayPalProfileSharingViewController alloc] initWithScopeValues:scopes
//                                                                         configuration:_payPalConfiguration
//                                                                              delegate:self];
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
                                 NSLog(@"%@", responseObject);
                                 self.loggedIn = YES;
                                 
                                 if(_successBlock)
                                     _successBlock(DBPayPalBindingStateDone, nil);
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 NSString *message;
                                 
                                 if (operation.response.statusCode == 400) {
                                     message = operation.responseObject[@"description"];
                                 }
                                 
                                 if(_successBlock)
                                     _successBlock(DBPayPalBindingStateFailure, message);
                             }];
}

#pragma mark - PayPalFuturePaymentDelegate methods

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
    if(self.successBlock)
        self.successBlock(DBPayPalBindingStateCancelled, nil);
    
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

#pragma mark - PayPalProfileSharingDelegate methods

- (void)userDidCancelPayPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController{
    if(self.successBlock)
        self.successBlock(DBPayPalBindingStateCancelled, nil);
    
    if([self.delegate respondsToSelector:@selector(payPalManager:shouldDismissViewController:)]){
        [self.delegate payPalManager:self shouldDismissViewController:profileSharingViewController];
    }
}

- (void)payPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController userDidLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization{
    [self sendAuthorizationToServer:profileSharingAuthorization];
    
    if([self.delegate respondsToSelector:@selector(payPalManager:shouldDismissViewController:)]){
        [self.delegate payPalManager:self shouldDismissViewController:profileSharingViewController];
    }
}

@end
