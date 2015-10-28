//
//  DBSubscriptionVariant.h
//  DoubleB
//
//  Created by Balaban Alexander on 16/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBSubscriptionVariant : NSObject <NSCoding>

@property (strong, nonatomic) NSString *variantId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *variantDescription;
@property (nonatomic) NSInteger count;
@property (nonatomic) double price;
@property (nonatomic) NSInteger period;

- (instancetype)initWithResponseDict:(NSDictionary *)dict;

@end
