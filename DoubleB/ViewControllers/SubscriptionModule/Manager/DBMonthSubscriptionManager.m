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

@implementation DBMonthSubscriptionVariant

- (instancetype)initWithResponseDict:(NSDictionary *)dict{
    self = [super init];
    
    self.variantId = [dict getValueForKey:@"id"] ?: @"";
    self.name = [dict getValueForKey:@"title"] ?: @"";
    self.variantDescription = [dict getValueForKey:@"description"] ?: @"";
    self.count = [[dict getValueForKey:@"amount"] intValue];
    self.price = [[dict getValueForKey:@"price"] doubleValue];
    self.period = [[dict getValueForKey:@"days"] intValue];
    
    return self;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBMonthSubscriptionVariant alloc] init];
    if(self != nil){
        _variantId = [aDecoder decodeObjectForKey:@"_variantId"];
        _name = [aDecoder decodeObjectForKey:@"_name"];
        _variantDescription = [aDecoder decodeObjectForKey:@"_variantDescription"];
        _count = [[aDecoder decodeObjectForKey:@"_count"] integerValue];
        _price = [[aDecoder decodeObjectForKey:@"_price"] doubleValue];
        _period = [[aDecoder decodeObjectForKey:@"_period"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_variantId forKey:@"_variantId"];
    [aCoder encodeObject:_name forKey:@"_name"];
    [aCoder encodeObject:_variantDescription forKey:@"_variantDescription"];
    [aCoder encodeObject:@(_count) forKey:@"_count"];
    [aCoder encodeObject:@(_price) forKey:@"_price"];
    [aCoder encodeObject:@(_period) forKey:@"_period"];
}

@end

@implementation DBMonthSubscriptionManager

- (void)synchWithResponseInfo:(NSDictionary *)infoDict{
    
}

- (void)buySubscription:(DBMonthSubscriptionVariant *)variant
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
                                    [variants addObject:[[DBMonthSubscriptionVariant alloc] initWithResponseDict:variantDict]];
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

@end
