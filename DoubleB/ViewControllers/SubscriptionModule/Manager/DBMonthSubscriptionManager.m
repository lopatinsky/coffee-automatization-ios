//
//  DBMonthSubscriptionManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBMonthSubscriptionManager.h"
#import "DBAPIClient.h"
#import "DBCardsManager.h"

@implementation DBMonthSubscriptionManager

- (void)buySubscription:(void(^)(BOOL success, NSString *errorMessage))callback{
    
    NSDictionary *params= @{@"return_url": @"alpha-payment://return-page",
                            @"type_id": @1,
                            @"card_pan": [DBCardsManager sharedInstance].defaultCard.pan,
                            @"binding_id": [DBCardsManager sharedInstance].defaultCard.token};
    
    [[DBAPIClient sharedClient] POST:@"subscription/buy"
                          parameters:params
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

@end
