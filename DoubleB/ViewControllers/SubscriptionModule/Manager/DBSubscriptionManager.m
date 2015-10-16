//
//  DBMonthSubscriptionManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBSubscriptionManager.h"
#import "DBAPIClient.h"
#import "DBCardsManager.h"

@interface DBSubscriptionManager()

@property (nonatomic, strong) NSMutableArray *subscriptionVariants;

@end

@implementation DBSubscriptionManager

- (instancetype)init {
    self = [super init];
    
    self.subscriptionVariants = [NSMutableArray new];
    
    return self;
}

- (void)synchWithResponseInfo:(NSDictionary *)infoDict{
    
}

- (void)buySubscription:(DBSubscriptionVariant *)variant
               callback:(void(^)(BOOL success, NSString *errorMessage))callback{
    
    NSDictionary *params= @{@"return_url": @"alpha-payment://return-page",
                            @"type_id": @1,
                            @"card_pan": [DBCardsManager sharedInstance].defaultCard.pan,
                            @"binding_id": [DBCardsManager sharedInstance].defaultCard.token};
    
    [[DBAPIClient sharedClient] POST:@"subscription/buy"
                          parameters:@{@"payment" : [params encodedString],
                                       @"tariff_id" : variant.variantId}
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if(callback)
                                     callback(YES, nil);
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 NSString *errorMessage;
                                 if (operation.response.statusCode == 400) {
                                     errorMessage = operation.responseObject[@"description"];
                                 }
                                 
                                 if(callback)
                                     callback(NO, errorMessage);
                             }];
}

- (void)checkSubscriptionVariants:(void(^)(NSArray *variants))success
                          failure:(void(^)(NSString *errorMessage))failure{
    [[DBAPIClient sharedClient] GET:@"subscription/tariffs"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSMutableArray *variants = [NSMutableArray new];
                                for (NSDictionary *variantDict in responseObject[@"tariffs"]){
                                    [variants addObject:[[DBSubscriptionVariant alloc] initWithResponseDict:variantDict]];
                                }
                                
                                self.subscriptionVariants = variants;
                                
                                if(success)
                                    success(variants);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(failure)
                                    failure(nil);
                            }];
}

- (NSArray<DBSubscriptionVariant *> *)subscriptionVariants {
    return _subscriptionVariants;
}

@end
