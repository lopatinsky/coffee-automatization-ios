//
//  IHPaymentManager.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 03.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "IHPaymentManager.h"
#import "DBCardsManager.h"
#import "IHWebPageViewController.h"
#import "DBAPIClient.h"
#import "DBClientInfo.h"

#define PAYMENT_TYPES_URL @"payment/payment_types"
#define PAYMENT_REGISTRATION_URL @"payment/register"
#define CHECK_ORDER_STATUS_URL @"payment/status"
#define CHECK_EXTENDET_ORDER_STATUS_URL @"payment/extended_status"
#define LOCK_PAYMENT_URL @"payment/payment_binding"
#define UNLOCK_PAYMENT_URL @"payment/reverse"
#define UNBIND_CARD_URL @"payment/unbind"

NSString *const kDBDefaultsAvailablePaymentTypes = @"kDBDefaultsAvailablePaymentTypes";

NSString *const kDBPaymentErrorDefault = @"kDBPaymentErrorDefault";
NSString *const kDBPaymentErrorCardNotUnique = @"kDBPaymentErrorCardNotUnique";
NSString *const kDBPaymentErrorWrongCardData = @"kDBPaymentErrorWrongCardData";
NSString *const kDBPaymentErrorCardLimitExceeded = @"kDBPaymentErrorCardLimitExceeded";
NSString *const kDBPaymentErrorNoInternetConnection = @"kDBPaymentErrorNoInternetConnection";

@interface IHPaymentManager()

@property(weak, nonatomic) UINavigationController *navigationController;

@end

@implementation IHPaymentManager

+ (instancetype)sharedInstance
{
    static IHPaymentManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [IHPaymentManager new];
    });
    return instance;
}

- (BOOL)paymentTypeAvailable:(PaymentType)type{
    NSArray *paymentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsAvailablePaymentTypes];
    
    return [paymentTypes containsObject:@(type)];
}

- (void)synchronizePaymentTypes {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *paymentTypes = [defaults objectForKey:kDBDefaultsAvailablePaymentTypes];
    if (!paymentTypes) {
        paymentTypes = @[@(PaymentTypeCash) ];
        [defaults setObject:paymentTypes forKey:kDBDefaultsAvailablePaymentTypes];
        [defaults synchronize];
    }

    [[DBAPIClient sharedClient] GET:PAYMENT_TYPES_URL
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                //NSLog(@"%@", responseObject);
                                NSMutableArray *array = [NSMutableArray array];
                                for (NSDictionary *paymentType in responseObject[@"payment_types"]) {
                                    [array addObject:@([paymentType[@"id"] intValue])];
                                }
                                [defaults setObject:array forKey:kDBDefaultsAvailablePaymentTypes];
                                [defaults synchronize];
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                            }];
}

-(void)bindNewCardForClient:(NSString *)clientId
          completionHandler:(void(^)(BOOL success, NSString *message, NSDictionary *items))completionHandler {
    if(clientId){
        [self registerPayment:@100 forClient:clientId withCard:nil completionHandler:completionHandler];
    }
}

-(void)registerPayment:(NSNumber *)sum
             forClient:(NSString *)clientId
              withCard:(NSString *)cardToken
     completionHandler:(void(^)(BOOL success, NSString *message, NSDictionary *items))completionHandler {

    self.orderDate = (NSInteger)[[NSDate date] timeIntervalSince1970] + arc4random() % 1000;
    
    NSDictionary *params = @{
            @"amount" : sum,
            @"orderNumber": @(self.orderDate),
            @"clientId": clientId,
            @"returnUrl": @"alpha-payment://return-page"
    };
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[DBAPIClient sharedClient] POST:PAYMENT_REGISTRATION_URL
                             parameters:params
                                success:^(AFHTTPRequestOperation *task, id responseObject) {
                                    //NSLog(@"%@", responseObject);
                                    NSDictionary *response = responseObject;
                                    
                                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                    
                                    NSInteger errorCode = [self errorCodeInResponse:response];
                                    if(errorCode == 0){
                                        if (!cardToken) {
                                            IHWebPageViewController *viewController = [IHWebPageViewController new];
                                            viewController.hidesBottomBarWhenPushed = YES;
                                            viewController.sourceUrl = response[@"formUrl"];
                                            
                                            NSString *phone = [DBClientInfo sharedInstance].clientPhone.value;
                                            if (phone) {
                                                viewController.sourceUrl = [viewController.sourceUrl stringByAppendingFormat:@"&phone=%@",
                                                                            [phone stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                            }
                                            viewController.sourceUrl = [viewController.sourceUrl stringByAppendingString:@"&app=doubleb"];
                                            
                                            if(self.navigationController.topViewController)
                                            
                                            viewController.completionHandler = ^(BOOL success) {
                                                if (success) {
                                                    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                                    [self checkOrderStatus:response[@"orderId"]
                                                                   forCard:cardToken
                                                     withCompletionHandler:^(BOOL s, NSString *message, NSDictionary *items) {
                                                        [self.navigationController popViewControllerAnimated:YES];
                                                        completionHandler(s, message, items);
                                                        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                                    }];
                                                } else {
                                                    completionHandler(NO, kDBPaymentErrorDefault, nil);
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                                }
                                            };
                                            [self.navigationController setNavigationBarHidden:NO animated:YES];
                                            [self.navigationController pushViewController:viewController animated:YES];
                                        } else {
                                            [self lockPaymentForOrder:response[@"orderId"]
                                                              forCard:cardToken
                                                    completionHandler:completionHandler];
                                        }
                                    } else {
                                        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                        completionHandler(NO, kDBPaymentErrorDefault, nil);
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                    NSLog(@"%@", error);
                                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                    
                                    if(error.code == -1009){
                                        completionHandler(NO, kDBPaymentErrorNoInternetConnection, nil);
                                    } else {
                                        completionHandler(NO, kDBPaymentErrorDefault, nil);
                                    }
                                }];
}

- (void)checkOrderStatus:(NSString *)orderId
                 forCard:(NSString *)cardToken
   withCompletionHandler:(void(^)(BOOL success, NSString *message, NSDictionary *items))completionHandler {
    NSDictionary *params = @{
            @"orderId": orderId
    };
    
    [[DBAPIClient sharedClient] POST:CHECK_ORDER_STATUS_URL
                             parameters:params
                                success:^(AFHTTPRequestOperation *task, id responseObject) {
                                    //NSLog(@"%@", responseObject);
                                    NSDictionary *response = responseObject;
                                    
                                    NSInteger errorCode = [self errorCodeInResponse:responseObject];
                                    
                                    if(errorCode == 0){
                                        if([response[@"OrderStatus"] integerValue] == 1 && !cardToken){
                                            [self unlockPaymentForOrder:orderId];
                                            
                                            // try to add cardToken to secure storage
                                            DBPaymentCard *card = [[DBPaymentCard alloc] init:response[@"bindingId"] pan:response[@"Pan"]];
                                            if([[DBCardsManager sharedInstance] addCard:card]){
                                                completionHandler(YES, nil, nil);
                                            } else {
                                                completionHandler(NO, kDBPaymentErrorCardNotUnique, nil);
                                            }
                                        } else {
                                            completionHandler(NO, kDBPaymentErrorDefault, nil);
                                        }
                                    } else {
                                        [self checkExtendedOrderStatus:orderId
                                                           orderNumber:responseObject[@"OrderNumber"]
                                                 withCompletionHandler:completionHandler];
                                    }
                                } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                    NSLog(@"%@", error);
                                    
                                    if(error.code == -1009){
                                        completionHandler(NO, kDBPaymentErrorNoInternetConnection, nil);
                                    } else {
                                        completionHandler(NO, kDBPaymentErrorDefault, nil);
                                    }
                                }];
}

- (void)checkExtendedOrderStatus:(NSString *)orderId
                     orderNumber:(NSString *)orderNumber
           withCompletionHandler:(void(^)(BOOL success, NSString *message, NSDictionary *items))completionHandler{
    [[DBAPIClient sharedClient] POST:CHECK_EXTENDET_ORDER_STATUS_URL
                              parameters:@{@"orderId": orderId}
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     //NSLog(@"%@", responseObject);
                                     
                                     NSString *jsonString = @"";
                                     if(responseObject[@"alfa_response"]){
                                         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject[@"alfa_response"]
                                                                                            options:NSJSONWritingPrettyPrinted
                                                                                              error:nil];
                                         jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                     }
                                     
                                     NSInteger errorCode = [self errorCodeInResponse:responseObject];
                                     
                                     switch (errorCode) {
                                         case 1:
                                             completionHandler(NO, kDBPaymentErrorCardLimitExceeded, @{@"alfaResponse": jsonString});
                                             break;
                                             
                                         case 2:
                                             completionHandler(NO, kDBPaymentErrorWrongCardData, @{@"alfaResponse": jsonString});
                                             break;
                                             
                                         default:
                                             completionHandler(NO, responseObject[@"description"], @{@"alfaResponse": jsonString});
                                             break;
                                     }
                                     
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     NSLog(@"%@", error);
                                     
                                     if(error.code == -1009){
                                         completionHandler(NO, kDBPaymentErrorNoInternetConnection, nil);
                                     } else {
                                         completionHandler(NO, kDBPaymentErrorDefault, nil);
                                     }
                                 }];
}

-(void)unbindCard:(NSString *)cardToken{
    NSDictionary *params = @{
                             @"bindingId": cardToken
                             };
    
    [[DBAPIClient sharedClient] POST:UNBIND_CARD_URL
                              parameters:params
                                 success:^(AFHTTPRequestOperation *task, id responseObject) {
                                     //NSLog(@"%@", responseObject);
                                 } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                     NSLog(@"%@", error);
                                     [GANHelper analyzeEvent:@"remove_card_failed" label:@"" category:PAYMENT_SCREEN];
                                 }];
}

-(void)lockPaymentForOrder:(NSString *)orderId
                   forCard:(NSString *)cardToken
         completionHandler:(void(^)(BOOL success, NSString *message, NSDictionary *items))completionHandler {
    NSDictionary *params = @{
            @"bindingId": cardToken,
            @"mdOrder": orderId
    };
    
    [[DBAPIClient sharedClient] POST:LOCK_PAYMENT_URL
                              parameters:params
                                 success:^(AFHTTPRequestOperation *task, id responseObject) {
                                     //NSLog(@"%@", responseObject);
                                     
                                     [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                     
                                     NSInteger errorCode = [self errorCodeInResponse:responseObject];
                                     if(errorCode == 0){
                                         completionHandler(YES, nil, nil);
                                     } else {
                                         completionHandler(NO, kDBPaymentErrorDefault, nil);
                                     }
                                 } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                     NSLog(@"%@", error);
                                    
                                     if(error.code == -1009){
                                         completionHandler(NO, kDBPaymentErrorNoInternetConnection, nil);
                                     } else {
                                         completionHandler(NO, kDBPaymentErrorDefault, nil);
                                     }
                                 }];
}

- (void)unlockPaymentForOrder:(NSString *)orderId{
    NSDictionary *params = @{
            @"orderId": orderId
    };
    
    [[DBAPIClient sharedClient] POST:UNLOCK_PAYMENT_URL
                              parameters:params
                                 success:^(AFHTTPRequestOperation *task, id responseObject) {
                                     //NSLog(@"%@", responseObject);
                                 } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                     NSLog(@"%@", error);
                                 }];
}

- (NSInteger)errorCodeInResponse:(NSDictionary *)response{
    NSInteger code = 0;
    
    if (response[@"errorcode"]){
        code = [response[@"errorcode"] integerValue];
        return code;
    }
    if (response[@"errorCode"]){
        code = [response[@"errorCode"] integerValue];
        return code;
    }
    if (response[@"Errorcode"]){
        code = [response[@"Errorcode"] integerValue];
        return code;
    }
    if (response[@"ErrorCode"]){
        code = [response[@"ErrorCode"] integerValue];
        return code;
    }
    if (response[@"error_code"]){
        code = [response[@"error_code"] integerValue];
        return code;
    }
    if (response[@"error_Code"]){
        code = [response[@"error_Code"] integerValue];
        return code;
    }
    if (response[@"Error_code"]){
        code = [response[@"Error_code"] integerValue];
        return code;
    }
    if (response[@"Error_Code"]){
        code = [response[@"Error_Code"] integerValue];
        return code;
    }
    
    return code;
}

@end
